require_relative 'lib/k8s-client'
require_relative 'lib/heapster'
require_relative 'lib/agent'

auth_options = {
		    password: 'fdYveJAxWvNvbqNc',
		    username: 'admin'
		}

k8sclient = K8sclient.new
heapsterclient = Heapster.new auth_options
agent = MetricAgent.new auth_options
agent.startAgent('getHeapsterNodeUsageMetrics')