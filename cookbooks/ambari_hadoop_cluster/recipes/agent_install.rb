#
# Cookbook Name:: ambari_hadoop_cluster
# Recipe:: agent_install
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

package ['ntp', 'git-core', 'wget']

# remote_file '/vagrant/chefdk-0.10.0-1.el7.x86_64.rpm' do
#   source 'https://opscode-omnibus-packages.s3.amazonaws.com/el/7/x86_64/chefdk-0.10.0-1.el7.x86_64.rpm'
#   action :create
# end

remote_file '/etc/yum.repos.d/ambari.repo' do
  source 'http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.1.2/ambari.repo'
  action :create
end

# package 'chefdk' do
#   source '/vagrant/chefdk-0.10.0-1.el7.x86_64.rpm'
# end

bash 'additional_installs' do
  user 'root'
  code <<-EOH
  chkconfig ntpd on
  yum repolist
  EOH
end

package 'ambari-agent'

bash 'copy_ambari_agent_config' do
  user 'root'
  code <<-EOH
  cp /vagrant/agent/ambari-agent.ini /etc/ambari-agent/conf/ambari-agent.ini
  EOH
end

service "ambari-agent" do
  action [:enable, :restart]
end

execute 'load_blueprint' do
  command 'curl -H "X-Requested-By: ambari" -X POST -u admin:admin http://s.ambari.local:8080/api/v1/blueprints/beegdaat -d @/vagrant/beegdaat_blueprint.json'
end

execute 'create_cluster' do
  command 'curl -H "X-Requested-By: ambari" -X POST -u admin:admin http://s.ambari.local:8080/api/v1/clusters/beegdaat -d @/vagrant/create_cluster.json'
end

service "ntpd" do
  action [:enable, :restart]
end
