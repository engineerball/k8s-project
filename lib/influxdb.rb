require 'influxdb'
require 'yaml'
require 'json'

class Influxdb

	def initialize()
		config = YAML.load_file('conf/database.yaml')
		
		if @environment == 'production'
			@server = config['influxdb_production']['server']
			@username = config['influxdb_production']['username']
			@password = config['influxdb_production']['password']
			@database = config['influxdb_production']['databasename']
		elsif @environment == 'staging'
			@server = config['influxdb_development']['server']
			@username = config['influxdb_development']['username']
			@password = config['influxdb_development']['password']
			@database = config['influxdb_development']['databasename']
		else
			@server = config['influxdb_development']['server']
			@username = config['influxdb_development']['username']
			@password = config['influxdb_development']['password']
			@database = config['influxdb_development']['databasename']
		end

		@influxdb = InfluxDB::Client.new host: @server, database: @database, username: @username, password: @password
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
