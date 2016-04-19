require_relative 'lib/include'

auth_options = {
		    password: 'fdYveJAxWvNvbqNc',
		    username: 'admin'
		}

k8sclient = K8sclient.new
heapsterclient = Heapster.new auth_options
#p heapsterclient.getHeapsterNodeUsageMetrics
#agent = MetricAgent.new auth_options
#agent.handleAgent('getHeapsterNodeUsageMetrics')

influxclient = Influxdb.new
#p influxclient.getQueryMetric('cpu', 'nodes')
#p influxclient.getQueryMetric('memory', 'nodes')

@@redis = Redis.new(:host => $REDIS_HOST, :port => $REDIS_PORT)
#current_cpu = influxclient.getQueryMetric('cpu', 'pods')

scal = Scaling.new
#future_load = scal.predicFutureLoads(current_cpu, 120)
#heapsterclient.getHeapsterCPUPodsRequestMetrics('default','my-nginx-gtge8')/


#while true do
	#p influxclient.getQueryMetric('cpu', 'pods')
	#@@redis.set('current_metric', current_cpu)
#	scal.scaleMonitoring('cpu', 'pods', 5, 40, 20, 7, 0)
#	p total_pods = k8sclient.getTotalRC('my-nginx', 'default')
#	sleep 60
#end
total_pods = k8sclient.getTotalPods 'default'
rawcpu = Hash.new(0)
total_pods.each do |index,pod|
	rawcpu[pod] = k8sclient.getPodsCPUCore pod
end

agent = Agent.new auth_options
rawcpu.each do |podname,podcpucore|
	cpuusage = agent.getPodsCPUUsage podname
	puts cpuusage
end
pod_cpu = Hash.new(0)
pod_cpu = influxclient.getPodsCPUUsagePercentByPods('my-nginx')
puts pod_cpu_usage = agent.calculateCPUUsage(pod_cpu)
puts pod_avg_cpu_usage = agent.getAveragePodsCPUUsage(pod_cpu_usage)

#agent = Agent.new

#agent.getPodsCPUUsage 
