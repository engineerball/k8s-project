require 'json'
require 'daemons'
require 'exponential_backoff'
require_relative 'heapster'
require_relative 'influxdb'
require_relative 'Agent'

class Agent

	def initialize()
		@heapster = Heapster.new
		@influxdb = Influxdb.new
		@k8sclient = K8sclient.new
	end

	def writeDB(data)
		@influxdb.writeQuery(data)
  end

	def startNodesAgent(functionname)
		data = Hash.new
		data = {
			'type' => 'nodes',
			'metrics' => @heapster.send(functionname)
		}
  	writeDB(data)
	end

	def startPodsAgent(functionname)
		data = Hash.new
		data = {
			'type' => 'pods',
			'metrics' => @heapster.send(functionname)
		}
		writeDB(data)
	end

	def getPodsCPUUsage(pods_label)
		pod = @k8sclient.getTotalPodByName(pods_label)
		pod_data = Hash.new(0)
		pod.each do |index, pod_name|
			pod_name =~ /(.*)-(.*)?/
			pods_filter = $1

			query = "SELECT pod_name, value FROM \"cpu\/usage\" WHERE pod_name =~ /.*#{pod_name}.*/ AND time > now() - 150s GROUP BY pod_name ORDER BY time DESC LIMIT 2"
			data = @influxdb.query(query)
			result = data['results'][0]['series']
			result.each_with_index do |(key, value), index|
			   pod_name = key['tags']['pod_name']
				 key['values'][0][1]
			   cpu_delta = key['values'][0][1] - key['values'][1][1]
				 pod_data[pod_name] = cpu_delta
			 end
		end
		cpu_usage_metric = calculateCPUUsage(pod_data)
		return cpu_usage_metric
	end

	def calculateCPUUsage(data_metric)
		pod_cpu_usage = Hash.new(0)
		cpuUsage = 0
		intervalInNS = 60000000000.0
		if data_metric
			data_metric.each do |podname, value|
				num_cores = @k8sclient.getPodsCPUCore(podname)
				if value
					cpuUsage = ((value / intervalInNS) / num_cores) * 100
					if cpuUsage > 100
						cpuUsage = 100
					end
				end
				pod_cpu_usage[podname] = cpuUsage
			end
		end
		return pod_cpu_usage
	end

	def getAveragePodsCPUUsage(data_metric)
		total_pods = data_metric.count
		total_cpu_usage = 0
		data_metric.each do |podname, value|
			total_cpu_usage +=value
		end
		average = total_cpu_usage / total_pods
		return average
	end

	def getPodsCPUUsagePercentByPods(pods_name)
		data = Hash.new(0)
		query = "SELECT value FROM \"cpu\/usage\" where pod_name =~ /.*#{pods_name}.*/ and time > now() - 150s GROUP BY  pod_name ORDER BY time DESC LIMIT 2"
		result = @influxdb.makeHttpRequest(query)
		result[0]['points'].each do |time, value, pod_name|
		 	data[pod_name] = value
		end
		return data
	end

	def adjustTime(podname)
		dataset = Array.new(0)

		minimal_interval = 0.0
		maximal_elapsed_time = 60.0

		backoff = ExponentialBackoff.new(minimal_interval, maximal_elapsed_time)
		p backoff
		backoff.intervals.each do |interval|
			p dataset = @influxdb.getPodsCPUUsagePercentByPod(podname)
			item = 0
			if dataset[0]
				dataset[0]['points'].each  do |time, value|
					if value
						item +=1
					end
				end
			else
				puts "dataset is nil"
			end

			puts "Total item = #{item}"

			if item.to_i % 2 == 1 or item == 0
				puts "Sleep #{interval}"
				sleep interval
				return false
			elsif item.to_i % 2 == 0
				return true
				break
			end
		end
	end

	#End class
end
