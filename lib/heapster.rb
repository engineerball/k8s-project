require 'json'
require 'rest-client'
require 'net/http'
require 'net/https'

class Heapster
	def initialize()
		@kubernates_api = "#{$k8s_api}v1/"
		@heapster_api_uri = "#{@kubernates_api}/proxy/namespaces/kube-system/services/heapster/api/v1/"
		@auth_options = $k8s_auth
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

	def getHeapsterClusterMemoryLimitMetrics()
		uri = @heapster_api_uri + "model/metrics/memory-limit"
		result = createClientRequest uri
		data = JSON.parse result
		return data
	end

	def getHeapsterClusterCPULimitMetrics()
		uri = @heapster_api_uri + "model/metrics/cpu-limit"
		result = createClientRequest uri 
		data = JSON.parse result
		return data
	end

	def getHeapsterNodeUsageMetrics()
		uri = @heapster_api_uri + "model/nodes/"
		result = createClientRequest uri 
		data = JSON.parse result
		data.each do |node|
			node_name = node['name']
			node_cpu_usage = node['cpuUsage']
			node_mem_usage = node['memUsage']
		end
		return data
	end

	def getHeapsterPodsUsageMetrics(namespace_name='default')
		uri = @heapster_api_uri + "model/namespaces/#{namespace_name}/pods/"
		result = createClientRequest uri
		data = JSON.parse result
		data.each do |node|
			node
		end
		return data
	end

	def getHeapsterCPUPodsRequestMetrics(namespace_name='default', podname)
		uri = @kubernates_api + "namespaces/#{namespace_name}/pods/#{podname}"
		#uri = @heapster_api_uri + "model/namespaces/#{namespace_name}/pods/"
		result = createClientRequest uri
		data = JSON.parse result
		request = data['spec']['containers'][0]['resources']['requests']
		cpu = request['cpu']
		return cpu
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