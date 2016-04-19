require 'yaml'
require 'json'
require 'net/http'
require 'net/https'
require 'kubeclient'


class K8sclient
	def initialize()
		clusters = nil
		cluster = nil
		@ca = nil
		@client_cert = nil
		@client_key = nil
		users = nil
		user = nil

		kubeconfig = YAML.load_file('/home/vagrant/.kube/config')
		clusters = kubeconfig['clusters']
		clusters.each_with_index {|val, index| cluster = val }
		@ca =  cluster['cluster']['certificate-authority-data'] 
		users = kubeconfig['users']
		users.each_with_index do |val,index|  
						unless val['user']['client-certificate-data'].nil? || @client_cert = val['user']['client-certificate-data'] 
						end
		end
		users.each_with_index do |val,index|  
						unless val['user']['client-key-data'].nil? || @client_key = val['user']['client-key-data'] 
						end
		end

		ssl_options = {
		  ca_file:     'ssl/ca.crt',
			verify_ssl: OpenSSL::SSL::VERIFY_NONE
		}

		@auth_options = {
		    password: 'dS6z2MLZ6yPEGovO',
		    username: 'admin'
		}

		@CLIENT = Kubeclient::Client.new 'https://146.148.82.110/api/', "v1", ssl_options: ssl_options, auth_options: @auth_options
	end

	def getTotalRC(rc_name, rc_namespace = 'default')
		#p pods = @CLIENT.get_pods(label_selector: "name=#{label}")
		rc = @CLIENT.get_replication_controller(rc_name, rc_namespace)
		return rc.spec.replicas
	end

	def getTotalPods(namespace = 'defualt')
		pods_name = Hash.new(0)
		pods = @CLIENT.get_pods(namespace: 'default')
		pods.each_with_index do |(key,value),index|
			pods_name[index] = key.metadata.name
		end
		return pods_name
	end

	def getPodsCPUCore(pods_name, pods_namespace = 'default')
		pods = @CLIENT.get_pod pods_name, pods_namespace
		container = pods.spec.containers
		h1 = Hash[*container.flatten(1)]
		cpu_core = h1[:resources][:requests][:cpu]

		# Convert CPU millicore to core
		if cpu_core.include? 'm'
			cpu_core = cpu_core.to_i * 0.001
		end
		return cpu_core
	end

#End class	
end
