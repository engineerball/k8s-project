require 'json'
require 'rest-client'
require 'net/http'
require 'net/https'

def getHeapsterModelMetrics(uri, 
								auth_options
								)
	model_uri = uri + "model/metrics/"
	result = createClientRequest model_uri, auth_options 
	data = JSON.parse result.body
end

def getHeapsterClusterMemoryUsageMetrics(api_uri, auth_options)
	uri = api_uri + "model/metrics/memory-usage"
	result = createClientRequest uri, auth_options 
	data = JSON.parse result.body
	p data
end

def getHeapsterClusterCPUUsageMetrics(api_uri, auth_options)
	uri = api_uri + "model/metrics/cpu-usage"
	result = createClientRequest uri, auth_options 
	data = JSON.parse result.body
	p data
end

def getHeapsterNodeUsageMetrics(api_uri, auth_options)
	uri = api_uri + "model/nodes/"
	result = createClientRequest uri, auth_options 
	data = JSON.parse result.body
	data.each do |node|
		p node_name = node['name']
		p node_cpu_usage = node['cpuUsage']
		p node_mem_usage = node['memUsage']
	end
end

def getHeapsterPodsUsageMetrics(api_uri, auth_options, namespace_name='default')
	uri = api_uri + "model/namespaces/#{namespace_name}/pods/"
	result = createClientRequest uri, auth_options 
	data = JSON.parse result.body
	data.each do |node|
		p node
	end
end

def createClientRequest(uri,auth_options)
	@auth_options = auth_options
	basic_auth_username = @auth_options[:username]
	basic_auth_password = @auth_options[:password]

	uri = URI.parse(uri)
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE

	request = Net::HTTP::Get.new(uri.request_uri)
	request.basic_auth(basic_auth_username, basic_auth_password)

	response = http.request(request)

	return response
end