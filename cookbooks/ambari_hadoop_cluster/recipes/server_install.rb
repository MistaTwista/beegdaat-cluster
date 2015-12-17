#
# Cookbook Name:: ambari_hadoop_cluster
# Recipe:: server_install
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
package ['ntp', 'git-core', 'wget', 'postgresql-jdbc']

remote_file '/vagrant/chefdk-0.10.0-1.el7.x86_64.rpm' do
  source 'https://opscode-omnibus-packages.s3.amazonaws.com/el/7/x86_64/chefdk-0.10.0-1.el7.x86_64.rpm'
  action :create
end

remote_file '/etc/yum.repos.d/ambari.repo' do
  source 'http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.1.2/ambari.repo'
  action :create
end

package 'chefdk' do
  source '/vagrant/chefdk-0.10.0-1.el7.x86_64.rpm'
end

bash 'additional_installs' do
  user 'root'
  code <<-EOH
  chkconfig ntpd on
  yum repolist
  EOH
end

package 'ambari-server'

bash 'ambari_server_setup' do
  user 'root'
  code <<-EOH
  ambari-server setup -s
  ambari-server setup --jdbc-db=postgres --jdbc-driver=/usr/share/java/postgresql-jdbc.jar
  EOH
end

bash 'postgres_settings' do
  user 'root'
  code <<-EOH
  echo "CREATE DATABASE rangerdb;" | sudo -u postgres psql -U postgres
  echo "CREATE DATABASE ranger_audit;" | sudo -u postgres psql -U postgres
  echo "CREATE USER rangerdba WITH PASSWORD 'rangerdba';" | sudo -u postgres psql -U postgres
  echo "CREATE USER rangerlogger WITH PASSWORD 'rangerlogger';" | sudo -u postgres psql -U postgres
  echo "GRANT ALL PRIVILEGES ON DATABASE rangerdb TO rangerdba;" | sudo -u postgres psql -U postgres
  echo "GRANT ALL PRIVILEGES ON DATABASE ranger_audit TO rangerlogger;" | sudo -u postgres psql -U postgres
  echo "ALTER USER postgres WITH PASSWORD 'postgres';" | sudo -u postgres psql -U postgres
  echo "local  all  ambari,rangerdba,rangerlogger  md5" >> /var/lib/pgsql/data/pg_hba.conf
  echo "host  all  ambari,rangerdba,rangerlogger  0.0.0.0/0  md5" >> /var/lib/pgsql/data/pg_hba.conf
  echo "host  all  ambari,rangerdba,rangerlogger  ::/0  md5" >> /var/lib/pgsql/data/pg_hba.conf
  EOH
end

service "ambari-server" do
  action [:enable, :restart]
end

service "postgresql" do
  action [:enable, :restart]
end

service "ntpd" do
  action [:enable, :restart]
end
