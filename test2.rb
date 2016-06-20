require_relative 'lib/include'


k8sclient = K8sclient.new
heapsterclient = Heapster.new
#p heapsterclient.getHeapsterNodeUsageMetrics
#agent = MetricAgent.new auth_options
#agent.handleAgent('getHeapsterNodeUsageMetrics')

influxclient = Influxdb.new

#@@redis = Redis.new(:host => $REDIS_HOST, :port => $REDIS_PORT)
scal = Scaling.new
agent = Agent.new

total_pods = k8sclient.getTotalPods 'default'

#Get random pods for adjust time to get data from influxdb
#random_pod = total_pods[rand(total_pods.length)]
#p random_pod
#agent.adjustTime random_pod


rawcpu = Hash.new(0)
pod_cpu = Hash.new(0)

	#Get random pods for adjust time to get data from influxdb
	#random_pod = total_pods[rand(total_pods.length)]
	#p random_pod

	#flag_adjusttime = agent.adjustTime random_pod
		#total_pods.each do |index,pod|
		#	rawcpu[pod] = k8sclient.getPodsCPUCore pod
		#end

		#rawcpu.each do |podname,podcpucore|
		while true
			puts pod_cpu_usage = agent.getPodsCPUUsage('default')

		#	puts "#{podname} #{cpu_usage}"
		#end

		#pod_cpu = influxclient.getPodsCPUUsagePercentByPods('my-nginx')
		#puts pod_cpu_usage = agent.calculateCPUUsage(pod_cpu)
		pod_avg_cpu_usage = agent.getAveragePodsCPUUsage(pod_cpu_usage)
		scale_to = scal.getNumberScaleUp(pod_cpu_usage, '20')
		puts "Pods average = #{pod_avg_cpu_usage}
		Scale to target #{scale_to}"
		total_pods = k8sclient.getTotalPods('default').count
		if total_pods < scale_to
			puts "Scale up"
			scal.scaleActions('my-nginx', scale_to)
			sleep 180
		elsif total_pods > scale_to
			puts "Scale down"
			scal.scaleActions('my-nginx', scale_to)
			sleep 300
		else
			sleep 60
		end

		rawcpu.clear
		pod_cpu.clear

	end
#agent = Agent.new

#agent.getPodsCPUUsage
