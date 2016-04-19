require 'yaml'
require 'json'
require 'net/http'
require 'net/https'
require 'kubeclient'
require_relative 'heapster'

clusters = nil
cluster = nil
@ca = nil
@client_cert = nil
@client_key = nil
users = nil
user = nil

kubeconfig = YAML.load_file('/home/vagrant/.kube/config')
#kubeconfig.inspect
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
auth_options = {
    password: 'dS6z2MLZ6yPEGovO',
    username: 'admin'
}

CLIENT = Kubeclient::Client.new 'https://146.148.82.110/api/', "v1", ssl_options: ssl_options, auth_options: auth_options

rc = CLIENT.get_replication_controller 'wordpress', 'default'
#puts rc
#p rc.spec.replicas
#pods = CLIENT.get_pod 'kube2sky', 'kube-system'
pods = CLIENT.get_pods(namespace: 'default')
pods.each do |k,v|
puts k.metadata.name
end



#client.update_replication_controller rc
#getHeapsterNodeUsageMetrics @heapster_api_uri, auth_options
#getHeapsterPodsUsageMetrics @heapster_api_uri, auth_options
