#
# Cookbook Name:: dns_publisher
# Recipe:: default
#
package "avahi-daemon"
package "avahi-utils"
package "python-avahi"

compute_derived_attributes
node[:dns_publisher][:config_file] = File.join(node[:deployment][:config_path], "dns_publisher.yml")

template node[:dns_publisher][:config_file] do
  path node[:dns_publisher][:config_file]
  source "dns_publisher.yml.erb"
  owner node[:deployment][:user]
  mode 0644
  notifies :restart, "service[vcap_dns_publisher]"
end

cf_bundle_install(File.expand_path(File.join(node["cloudfoundry"]["path"], "dns_publisher")))
add_to_vcap_components("dns_publisher")

service "vcap_dns_publisher" do
  provider CloudFoundry::VCapChefService
  supports :status => true, :restart => true, :start => true, :stop => true
  action [ :start ]
end