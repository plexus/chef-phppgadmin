#
# Cookbook Name:: phppgadmin
# Recipe:: default
#
# Copyright 2012, Ren Dao Solutions BVBA
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package 'phppgadmin' do
  action :install
end

case node[:phppgadmin][:webserver]
when 'nginx'
  ###
  # Make this more self-contained, use the Nginx cookbook if you need more
  # control over the nginx config.
  unless node['recipes'].include? 'nginx'
    package 'nginx' do
      action :install
    end
    
    service "nginx" do
      action :enable
      supports :start => true, :stop => true, :restart => true
    end
  end
  #
  ###

  package "php5-fpm" do
    action :install
  end
  
  template "/etc/nginx/sites-available/phppgadmin.conf" do
    source "phppgadmin-nginx.conf.erb"
    owner "root"
    group "root"
    mode "0640"
  end

  directory node[:phppgadmin][:log_dir] do
    owner "root"
    group "root"
    mode "0755"    
    action :create
  end

  link "/etc/nginx/sites-enabled/phppgadmin.conf" do
    to "/etc/nginx/sites-available/phppgadmin.conf"
    notifies :restart, "service[nginx]", :delayed
  end
end
