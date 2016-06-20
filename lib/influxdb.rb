require 'influxdb'
require 'yaml'
require 'json'
require 'typhoeus'
require 'uri'

class Influxdb

	def initialize()
		#@influxdb = InfluxDB::Client.new host: $influxdb_server, port: $influxdb_port, database: $influxdb_database, username: $influxdb_username, password: $influxdb_password
		@influxdb_http_uri = "http://#{$influxdb_server}:#{$influxdb_port}/query?u=#{$influxdb_username}&p=#{$influxdb_password}&db=#{$influxdb_database}"
		@influxdb_http_uri = "https://104.197.65.76/api/v1/proxy/namespaces/kube-system/services/monitoring-influxdb:8086/query?u=#{$influxdb_username}&p=#{$influxdb_password}&db=#{$influxdb_database}"
		@time_select = 0
	end

	def createDB()

	end


	def makeHttpRequest(query)
		 query = URI.encode(query)
		 data = Hash.new(0)
		 request = Typhoeus::Request.new(
		  "#{@influxdb_http_uri}&q=#{query}",
		  method: :get,
			ssl_verifypeer: false,
			userpwd: "#{$k8s_username}:#{$k8s_password}"
		  #body: {content: "q=#{data}"},
		  #headers: {'Content-Type'=> "application/x-www-form-urlencoded"},
		)
		 response = request.run
		 result = JSON.parse(response.body)
		 #result[0]['points'].each do |time, value, pod_name|
		 #	data[pod_name] = value
		 #end
		return result
	end

	# def writeQuery(data)
	# 	name = nil
	# 	cpu = nil
	# 	memory = nil
	# 	precission = 'm'
	# 	retention = '1h.cpu'
	#
	# 	type = data['type']
	# 	metrics = data['metrics']
	# 	metrics.each do |key,value|
	# 		name = key['name']
	# 		cpu = key['cpuUsage']
	# 		memory = key['memUsage']
	#
	# 		data = [
	# 			{
	# 				series: 'cpu',
	#     		tags: { host: name, type: type },
	#     		values: { value: cpu }
	# 			},
	# 			{
	# 				series: 'memory',
	# 				tags: { host: name, type: type },
	# 				values: { value: memory }
	# 			}
	# 		]
	#
	# 		@influxdb.write_points(data, precission)
	#
	# 	end
	# end

	def query(sql)
		#result = @influxdb.query sql
		result = makeHttpRequest sql
		return result
	end

	def getQueryMetric(metric, type)
		data = Hash.new
		data_metric = 0
		#query = "SELECT PERCENTILE(value,95) AS value FROM #{metric} WHERE time > now() - 2m AND type = '#{type}' GROUP BY time(2m) ORDER BY ASC LIMIT 1"
		query = "select mean(value) AS value FROM #{metric} WHERE time > now() - 2m AND type = '#{type}' GROUP BY time(1m) ORDER BY DESC LIMIT 1"
		result = @influxdb.query query
		p data = result[0]['values']
		data.each do |key|
			data_metric = key['value']
		end
		return data_metric
	end

	def getPodsCPUUsagePercentByPod(pods_label)
		pods_label =~ /(.*)-(.*)?/
		pods_filter = $1
		data = Array.new(0)

		puts query = "SELECT difference(value) AS value FROM \"cpu\/usage_ns_cumulative\" WHERE labels =~ /.*#{pods_filter}.*/ AND time > now() - 150s GROUP BY time(1m)"
		data = makeHttpRequest(query)
		#puts @time_select = adjustTime(data)
		return data
	end

	def getPodsCPUUsagePercentByPods(pods_label)
		#pods_label =~ /(.*)-(.*)?/
		#pods_filter = $1
		data = Hash.new(0)
		query = "select difference(value) as value from \"cpu\/usage_ns_cumulative\" where labels =~ /.*#{pods_label}.*/ and time > now() - 150s group by pod_name order asc"
		result = makeHttpRequest(query)
		result[0]['points'].each do |time, value, pod_name|
		 	data[pod_name] = value
		end
		return data
	end

	def adjustTime(dataset)
		p dataset[0]
		epoch_time = 0
		item = 1
		if dataset[0]
			dataset[0]['points'].each  do |time, value|
				#epoch_time = time
				if value
					item +=1
				end
			end
		else
			puts "dataset is nil"
		end

		puts "Total item = #{item}"

		if item.to_i % 2 == 1
			puts "Sleep 30"
			sleep 30
			return false
		elsif item.to_i % 2 == 0
			puts "Sleep 60"
			sleep 60
			return true
		end
	end
	#End class
end
