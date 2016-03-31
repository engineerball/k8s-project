require_relative 'lib/include'

auth_options = {
		    password: 'fdYveJAxWvNvbqNc',
		    username: 'admin'
		}

k8sclient = K8sclient.new
heapsterclient = Heapster.new auth_options
p heapsterclient.getHeapsterNodeUsageMetrics
#agent = MetricAgent.new auth_options
#agent.handleAgent('getHeapsterNodeUsageMetrics')

influxclient = Influxdb.new
#p influxclient.getQueryMetric('cpu', 'nodes')
#p influxclient.getQueryMetric('memory', 'nodes')

@@redis = Redis.new(:host => $REDIS_HOST, :port => $REDIS_PORT)
current_cpu = influxclient.getQueryMetric('cpu', 'pods')

scal = Scaling.new
#future_load = scal.predicFutureLoads(current_cpu, 120)


while true do
	p influxclient.getQueryMetric('cpu', 'pods')
	@@redis.set('current_metric', current_cpu)
	scal.scaleMonitoring('cpu', 'pods', 3, 40, 3, 5, 0)
	p total_pods = k8sclient.getTotalRC('my-nginx', 'default')
	sleep 60
end
