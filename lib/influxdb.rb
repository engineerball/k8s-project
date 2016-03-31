require 'influxdb'
require 'yaml'
require 'json'

class Influxdb

	def initialize()
		@influxdb = InfluxDB::Client.new host: $influxdb_server, database: $influxdb_database, username: $influxdb_username, password: $influxdb_password
	end

	def createDB()

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
		query = "SELECT PERCENTILE(value,95) AS value FROM #{metric} WHERE time > now() - 2m AND type = '#{type}' GROUP BY time(2m) ORDER BY ASC LIMIT 1"
		result = @influxdb.query query
		data = result[0]['values']
		data.each do |key|
			data_metric = key['value']
		end
		return data_metric
	end

end
