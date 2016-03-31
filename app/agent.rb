require 'json'
require_relative '../lib/include'
require_relative '../lib/agent'

auth_options = {
		    password: 'fdYveJAxWvNvbqNc',
		    username: 'admin'
		}

agent = MetricAgent.new auth_options

loop do
	agent.startNodesAgent('getHeapsterNodeUsageMetrics')
p	agent.startPodsAgent('getHeapsterPodsUsageMetrics')
	sleep 30
end
