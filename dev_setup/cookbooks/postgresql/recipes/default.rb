#
# Cookbook Name:: postgresql
# Recipe:: default
#
# Copyright 2011, VMware
#
#
#
%w[libpq-dev postgresql].each do |pkg|
  package pkg
end

case node['platform']
when "ubuntu"
  
when "ubuntu"
  bash "Install postgres-9.1" do
    code <<-EOH
apt-get install python-software-properties
add-apt-repository ppa:pitti/postgresql
apt-get -qy update
apt-get install -qy postgresql-9.1 postgresql-contrib-9.1
apt-get install -qy postgresql-server-dev-9.1 libpq-dev libpq5
EOH
  end
  
  ruby_block "postgresql_conf_update" do
    block do
      / \d*.\d*/ =~ `pg_config --version`
      pg_major_version = $&.strip

      # update postgresql.conf
      postgresql_conf_file = File.join("", "etc", "postgresql", pg_major_version, "main", "postgresql.conf")
      `grep "^\s*listen_addresses" #{postgresql_conf_file}`
      if $?.exitstatus != 0
        `echo "listen_addresses='#{node[:postgresql][:host]},localhost'" >> #{postgresql_conf_file}`
      else
        `sed -i.bkup -e "s/^\s*listen_addresses.*$/listen_addresses='#{node[:postgresql][:host]},localhost'/" #{postgresql_conf_file}`
      end

      # configure ltree.sql if necessary:
      if node[:postgresql][:ltree_in_template1]
        cf_pg_setup_ltree
      end
          

      # Cant use service resource as service name needs to be statically defined
      # For pg_major_version >= 9.0 the version does not appear in the name
      #`#{File.join("", "etc", "init.d", "postgresql-#{pg_major_version}")} restart`
      `#{File.join("", "etc", "init.d", "postgresql")} restart`
    end
  end
  
else
  Chef::Log.error("Installation of PostgreSQL is not supported on this platform.")
end
