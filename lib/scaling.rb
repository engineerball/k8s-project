require 'json'
require 'redis'

class Scaling
	def initialize()
		@@redis = Redis.new(:host => $REDIS_HOST, :port => $REDIS_PORT)
		@@influxclient = Influxdb.new
		@@k8sclient = K8sclient.new

	end

	def predicFutureLoads(load_avg, time_interval)
		t = time_interval
		#First derivative of current load average
		u = load_avg.to_f / time_interval
		# Second derivative of current load average
		a = load_avg.to_f / (time_interval ** 2)
		# Prediction future load
		s = (u * t) + 0.5 * a ** t

		puts "load_avg = #{load_avg}
		time_interval = #{time_interval}
		u = #{u}
		a = #{a}
		s = #{s}"

	end

	def scaleMonitoring(metric_type, node_type, min, max, scaling_step = 1, upper_treshold = 0, lower_treshold = 0)
		previous_metric = @@redis.get('current_metric').to_i
		current_metric = @@influxclient.getQueryMetric(metric_type, node_type)
		scaling_number = min

		current_node =  @@k8sclient.getTotalRC('my-nginx', 'default')
		scaling_node_to = current_node

		while (current_metric.to_i >= upper_treshold) do
			puts "SCALE Up
				current_metric = #{current_metric}
				previous_metric = #{previous_metric}"

				current_metric = @@influxclient.getQueryMetric(metric_type, node_type)
				previous_metric = @@redis.get('current_metric').to_i
			if current_metric >= previous_metric
				scaling_node_to = scaling_node_to + scaling_step
				if scaling_node_to > max
					scaling_node_to = max
				end
				p cmd = "kubectl scale --replicas=#{scaling_node_to} rc my-nginx"
				system(cmd)
			elsif current_metric < previous_metric && ((current_metric < upper_treshold) && (current_metric > lower_treshold))
				scaling_node_to = scaling_node_to - scaling_step
				if scaling_node_to < min
					scaling_node_to = min
				end
				p cmd = "kubectl scale --replicas=#{scaling_node_to} rc my-nginx"
				system(cmd)
			end
			# Update current_metric
			#current_metric = @@influxclient.getQueryMetric(metric_type, node_type)
			@@redis.set('current_metric', current_metric)
			sleep 30
		end

		current_node =  @@k8sclient.getTotalRC('my-nginx', 'default')
		scaling_node_to = current_node
		begin
			current_metric = @@influxclient.getQueryMetric(metric_type, node_type)
			previous_metric = @@redis.get('current_metric').to_i
			scaling_node_to = scaling_node_to - scaling_step
			puts "SCALE Down
			current_metric = #{current_metric}, previous_metric = #{previous_metric}, node= #{current_node}"
			if scaling_node_to < min
					scaling_node_to = min
			end
			if scaling_node_to != min
				p cmd = "kubectl scale --replicas=#{min} rc my-nginx"
				system(cmd)
				sleep 30
			end

			#current_metric = @@influxclient.getQueryMetric(metric_type, node_type)
			@@redis.set('current_metric', current_metric)
		end while (current_metric < lower_treshold)
	end

	def getNumberScaleUp(data_metric, target = 100)
		target_num_of_pods = 1
		current_pods_cpu_utilization = 0

		if data_metric
			data_metric.each do |pod, cpu|
				current_pods_cpu_utilization += cpu
			end
			if current_pods_cpu_utilization
				target_num_of_pods = (current_pods_cpu_utilization.to_f / target.to_f).ceil
			end
		end
		if target_num_of_pods == 0
			target_num_of_pods = 1
		end
		return target_num_of_pods
	end

	def scaleActions(rc_name, target_pods = 1)
		puts cmd = "kubectl scale --replicas=#{target_pods} rc #{rc_name}"
		#result = `#{cmd}`
	end

	#End class
end
