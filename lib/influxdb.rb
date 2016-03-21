require 'influxdb'
require 'yaml'

class Influxdb
	def createInstance()
		config = YAML.load_file('../conf/database.yaml')
		
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

	def writeQuery(name, data)
		
	end

	def getQuery

	end

end
