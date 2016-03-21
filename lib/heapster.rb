require 'json'
require 'rest-client'
require 'net/http'
require 'net/https'

class Heapster
	@auth_options
	def initialize(auth_options)
		@heapster_api_uri = 'https://104.154.39.146/api/v1/proxy/namespaces/kube-system/services/heapster/api/v1/'
		@auth_options = auth_options
	end

	def getHeapsterModelMetrics()
		model_uri = @heapster_api_uri + "model/metrics/"
		result = createClientRequest model_uri
		data = JSON.parse result
		return data
	end

	def getHeapsterClusterMemoryUsageMetrics()
		uri = @heapster_api_uri + "model/metrics/memory-usage"
		result = createClientRequest uri
		data = JSON.parse result
		return data
	end

	def getHeapsterClusterCPUUsageMetrics()
		uri = @heapster_api_uri + "model/metrics/cpu-usage"
		result = createClientRequest uri 
		data = JSON.parse result
		return data
	end

	def getHeapsterNodeUsageMetrics()
		uri = @heapster_api_uri + "model/nodes/"
		result = createClientRequest uri 
		data = JSON.parse result
		data.each do |node|
			p node_name = node['name']
			p node_cpu_usage = node['cpuUsage']
			p node_mem_usage = node['memUsage']
		end
		return data
	end

	def getHeapsterPodsUsageMetrics(namespace_name='default')
		uri = @heapster_api_uri + "model/namespaces/#{namespace_name}/pods/"
		result = createClientRequest uri
		data = JSON.parse result
		data.each do |node|
			p node
		end
		return data
	end

	def createClientRequest(uri)
		basic_auth_username = @auth_options[:username]
		basic_auth_password = @auth_options[:password]

		uri = URI.parse(uri)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE

		request = Net::HTTP::Get.new(uri.request_uri)
		request.basic_auth(basic_auth_username, basic_auth_password)

		response = http.request(request)

		return response.body
	end
end