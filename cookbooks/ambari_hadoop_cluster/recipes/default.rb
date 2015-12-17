#
# Cookbook Name:: ambari_hadoop_cluster
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

bash 'extract_module' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    echo #{extract_path} > extract_path.txt
    echo #{src_filename} > src_filename.txt
    echo "TEST" > #{extract_path}/testtest.txt
    EOH
  not_if { ::File.exists?(extract_path) }
end
