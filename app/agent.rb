require 'json'
require_relative '../lib/heapster'
require_relative '../lib/agent'

auth_options = {
		    password: 'fdYveJAxWvNvbqNc',
		    username: 'admin'
		}

agent = MetricAgent.new auth_options

loop do
	agent.startNodesAgent('getHeapsterNodeUsageMetrics')
	agent.startPodsAgent('getHeapsterPodsUsageMetrics')
	sleep 60
end
