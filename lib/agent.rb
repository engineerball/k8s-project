require 'json'
require 'daemons'
require_relative 'heapster'
require_relative 'influxdb'

class MetricAgent

	def initialize(auth_options)
		@auth_options = auth_options
		@heapster = Heapster.new auth_options
		@influxdb = Influxdb.new
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

end