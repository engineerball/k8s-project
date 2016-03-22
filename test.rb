require_relative 'lib/k8s-client'
require_relative 'lib/heapster'
require_relative 'lib/agent'

auth_options = {
		    password: 'fdYveJAxWvNvbqNc',
		    username: 'admin'
		}

#k8sclient = K8sclient.new
#heapsterclient = Heapster.new auth_options
#heapsterclient.getHeapsterNodeUsageMetrics
#agent = MetricAgent.new auth_options
#agent.handleAgent('getHeapsterNodeUsageMetrics')

influxclient = Influxdb.new
p influxclient.getQueryMetric('cpu', 'nodes')
p influxclient.getQueryMetric('memory', 'nodes')
p influxclient.getQueryMetric('cpu', 'pods')
p influxclient.getQueryMetric('memory', 'pods')
