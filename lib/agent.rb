require 'json'
require 'daemons'
require_relative 'heapster'
require_relative 'influxdb'
require_relative 'Agent'

class Agent

	def initialize(auth_options)
		@auth_options = auth_options
		@heapster = Heapster.new auth_options
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
		data = Hash.new(0)
		data = @influxdb.getPodsCPUUsagePercentByPod(pods_label)

		return data
	end

	def calculateCPUUsage(data_metric)
		pod_cpu_usage = Hash.new(0)
		cpuUsage = 0
		intervalInNS = 60000000000.0
		if data_metric
			data_metric.each do |podname, value|
				num_cores = @k8sclient.getPodsCPUCore(podname)
				cpuUsage = ((value / intervalInNS) / num_cores) * 100
				if cpuUsage > 100
					cpuUsage = 100
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
	#End class
end