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
		#users.each_with_index {|val,index|  @client_key = val['user']['client-key-data']}

		ssl_options = {
		##  client_cert: @client_cert,
		#  client_cert: OpenSSL::X509::Certificate.new(@client_cert),
		##  client_key:  @client_key,
		#  client_key:  OpenSSL::PKey::RSA.new(@client_key),
		#  ca_file:     @ca,
		# client_cert: OpenSSL::X509::Certificate.new(File.read('ssl/client.crt')),
		#  client_key:  OpenSSL::PKey::RSA.new(File.read('ssl/client.key')),
		  ca_file:     'ssl/ca.crt',
		#  verify_ssl:  OpenSSL::SSL::VERIFY_PEER
		verify_ssl: OpenSSL::SSL::VERIFY_NONE
		}

		@auth_options = {
		    password: 'fdYveJAxWvNvbqNc',
		    username: 'admin'
		}

		@CLIENT = Kubeclient::Client.new 'https://104.154.39.146/api/', "v1", ssl_options: ssl_options, auth_options: @auth_options
	end
end
