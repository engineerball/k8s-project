require 'influxdb'
require 'yaml'
require 'json'
require 'typhoeus'
require 'uri'

class Influxdb

	def initialize()
		@influxdb = InfluxDB::Client.new host: $influxdb_server, port: $influxdb_port, database: $influxdb_database, username: $influxdb_username, password: $influxdb_password 
		@influxdb_http_uri = "http://#{$influxdb_server}:#{$influxdb_port}/db/#{$influxdb_database}/series?u=#{$influxdb_username}&p=#{$influxdb_password}"
	end

	def createDB()

	end


	def makeHttpRequest(uri)
		 uri = URI.encode(uri)
		 data = Hash.new(0)
		 request = Typhoeus::Request.new(
		  "#{@influxdb_http_uri}&q=#{uri}",
		  method: :get,
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

	def writeQuery(data)
		name = nil
		cpu = nil
		memory = nil
		precission = 'm'
		retention = '1h.cpu'

		type = data['type']
		metrics = data['metrics']
		metrics.each do |key,value|
			name = key['name']
			cpu = key['cpuUsage']
			memory = key['memUsage']

			data = [
				{
					series: 'cpu',
	    		tags: { host: name, type: type },
	    		values: { value: cpu }
				},
				{
					series: 'memory',
					tags: { host: name, type: type },
					values: { value: memory }
				}
			]

			@influxdb.write_points(data, precission)

		end
		
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
		query = "SELECT difference(value) AS value FROM \"cpu\/usage_ns_cumulative\" WHERE labels =~ /.*#{pods_filter}.*/ AND time > now() - 3m GROUP BY time(1m) ORDER ASC LIMIT 2"
		data = makeHttpRequest(query)
		return data
	end

	def getPodsCPUUsagePercentByPods(pods_label)
		#pods_label =~ /(.*)-(.*)?/
		#pods_filter = $1
		data = Hash.new(0)
		query = "select difference(value) as value from \"cpu\/usage_ns_cumulative\" where labels =~ /.*#{pods_label}.*/ and time > now() - 3m group by pod_name order asc"
		result = makeHttpRequest(query)
		result[0]['points'].each do |time, value, pod_name|
		 	data[pod_name] = value
		end
		return data
	end

	#End class
end
