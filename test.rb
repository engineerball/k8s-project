require_relative 'lib/include'

auth_options = {
		    password: 'HQtBwDSEk4eLG8tc',
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
agent = Agent.new auth_options

total_pods = k8sclient.getTotalPods 'default'

#Get random pods for adjust time to get data from influxdb
random_pod = total_pods[rand(total_pods.length)]
p random_pod
agent.adjustTime random_pod


rawcpu = Hash.new(0)
pod_cpu = Hash.new(0)

while true

	#Get random pods for adjust time to get data from influxdb
	random_pod = total_pods[rand(total_pods.length)]
	p random_pod
	
	flag_adjusttime = agent.adjustTime random_pod
	# True or False
	if flag_adjusttime
		total_pods.each do |index,pod|
			rawcpu[pod] = k8sclient.getPodsCPUCore pod
		end

		rawcpu.each do |podname,podcpucore|
			cpu_usage = agent.getPodsCPUUsage podname

			puts "#{podname} #{cpu_usage}"
		end

		pod_cpu = influxclient.getPodsCPUUsagePercentByPods('my-nginx')
		puts pod_cpu_usage = agent.calculateCPUUsage(pod_cpu)
		puts pod_avg_cpu_usage = agent.getAveragePodsCPUUsage(pod_cpu_usage)
		puts scal.getNumberScaleUp(pod_cpu_usage, '30')
		rawcpu.clear
		pod_cpu.clear
	end
	puts "== Loop interval =="
	sleep 60
end
#agent = Agent.new

#agent.getPodsCPUUsage 
