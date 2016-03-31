require 'json'
require 'redis'

class Scaling
	def initialize()
		@@redis = Redis.new(:host => $REDIS_HOST, :port => $REDIS_PORT)
		@@influxclient = Influxdb.new

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
		step = 1
		while (current_metric >= upper_treshold) do
			puts "step #{step}
				current_metric = #{current_metric}
				previous_metric = #{previous_metric}"
			if current_metric >= previous_metric
				scaling_number = scaling_step * step
				if scaling_number > max
					scaling_number = max
				end
				p cmd = "kubectl scale --replicas=#{scaling_number} rc my-nginx"
				system(cmd)
			elsif current_metric < previous_metric
				scaling_number = scaling_number * (step / scaling_step)
				if scaling_number < min
					scaling_number = min
				end
				p cmd = "kubectl scale --replicas=#{scaling_number} rc my-nginx"
				system(cmd)
			end
			# Update current_metric
			current_metric = @@influxclient.getQueryMetric(metric_type, node_type)			
			step +=1
			sleep 60
		end

		while (current_metric <= lower_treshold) do
			scaling_number = scaling_number * (step / scaling_step)
			puts "current_metric = #{current_metric}
				previous_metric = #{previous_metric}"
			if scaling_number < min
					scaling_number = min
			end
			cmd = "kubectl scale --replicas=#{min} rc my-nginx"
			system(cmd)

			current_metric = @@influxclient.getQueryMetric(metric_type, node_type)
			step +=1 
			sleep 60
		end
	end
end