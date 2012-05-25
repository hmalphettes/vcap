# Compute the 'effective' deployment attributes
compute_derived_attributes

# convenience variables
ruby_version = node[:ruby][:version]
ruby_source = node[:ruby][:source]
ruby_path = node[:ruby][:path]

deployment_name=node[:deployment][:name]
Chef::Log.debug("#{deployment_name} is the current deployment_name")
raise "Not the expected deployment_name deployment_name: #{deployment_name}" if deployment_name != "intalio_devbox"

Chef::Log.debug("#{ruby_path} is the current ruby_path")
raise "deployment_name: #{deployment_name}; deployment_home: #{node[:deployment][:home]} Not the expected deployment_name ruby_path: #{ruby_path}" if ruby_path != "/home/ubuntu/cloudfoundry/.deployments/intalio_devbox/deploy/rubies/ruby-#{node[:ruby][:version]}"

do_install = true
if File.exists?("#{ruby_path}/bin/ruby") &&
   File.exists?("#{ruby_path}/bin/rake") &&
   File.exists?("#{ruby_path}/bin/gem") &&
   File.exists?("#{ruby_path}/bin/bundle")
  Chef::Log.debug("#{ruby_path} exists, looking if we should re-install ruby")
  ruby_version_regexp = node[:ruby][:version_regexp] || node[:ruby][:version].delete('-')
  ruby_version=`#{ruby_path}/bin/ruby --version`
  do_install = false if /#{ruby_version_regexp}/ =~ ruby_version
  if do_install
    Chef::Log.debug("#{ruby_path} exists, but the version #{ruby_version} is different: from the one expected: #{ruby_version_regexp}")
    FileUtils.rm_rf ruby_path
  end

  unless do_install
    version = node[:rubygems][:rake][:version]
    the_version=`#{ruby_path}/bin/rake --version`
    do_install = false if /#{ruby_version_regexp}/ =~ the_version
    if do_install
      Chef::Log.debug("#{ruby_path}/bin/rake exists, but the version #{the_version} is different: from the one expected: #{version}")
    end
  end

  unless do_install
    version = node[:rubygems][:version]
    the_version=`#{ruby_path}/bin/gem --version`
    do_install = false if /#{version}/ =~ the_version
    if do_install
      Chef::Log.debug("#{node[:ruby][:path]}/bin/gem exists, but the gem #{the_version} is different from the one expected: #{version}")
    end
  end

  unless do_install
    version = node[:rubygems][:bundler][:version]
    the_version=`#{ruby_path}/bin/bundle --version`
    do_install = false if /#{ruby_version_regexp}/ =~ the_version
    if do_install
      Chef::Log.debug("#{ruby_path}/bin/bundle exists, but the bundler #{the_version} is different: from the one expected: #{version}")
    end
  end

end

cf_ruby_install(ruby_version, ruby_source, ruby_path) if do_install
