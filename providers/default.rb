def whyrun_supported?
  true
end

use_inline_resources

def play_service(project_name, home_dir)
  # create pid directory
  directory new_resource.pid_dir do
    owner new_resource.user
    group new_resource.user
    mode 0755
    action :create
  end

  # make play script executable
  execute "chmod +x #{project_name}" do
    cwd "#{home_dir}/bin"
    action :run
  end

  service new_resource.servicename do
    init_command "/etc/init.d/#{new_resource.servicename}"
    supports status: true, start: true, stop: true, restart: true
    action :nothing
  end

  config_path =
    new_resource.config_file =~ %r{^/} ? new_resource.config_file : "#{home_dir}/#{new_resource.config_file}"

  # create play service
  template "/etc/init.d/#{new_resource.servicename}" do
    cookbook 'play'
    source "#{node['platform_family']}/play.init.erb"
    owner 'root'
    group 'root'
    mode 0755
    variables(
      servicename: new_resource.servicename,
      source: home_dir,
      executable: project_name,
      user: new_resource.user,
      pid_path: new_resource.pid_dir,
      config_file: config_path,
      args: new_resource.args.join(' ')
    )
    notifies :enable, "service[#{new_resource.servicename}]", :immediately
    notifies :start, "service[#{new_resource.servicename}]", :immediately
  end
end

action :install do
  converge_by(new_resource) do
    package 'unzip' do
      action :install
    end

    package 'rsync' do
      action :install
      only_if { node['platform'] == 'centos' }
    end

    user new_resource.user do
      comment 'play'
      system true
      shell '/bin/false'
      action :create
    end

    version = new_resource.version
    version ||= (new_resource.source).match(/-([\d|.|(-SNAPSHOT)]*)[-|.]/)[1] # http://rubular.com/r/X9K1KPkEpx

    ark new_resource.servicename do
      url new_resource.source
      checksum new_resource.checksum
      version version
      owner new_resource.user
      not_if { ::File.directory?(new_resource.source) }
      action :install
    end

    project_name = new_resource.project_name
    project_name ||= (new_resource.source).match(%r{.*/(.*)-[0-9].*})[1] # http://rubular.com/r/X9PUgZl0UW

    home_dir = ::File.directory?(new_resource.source) ? new_resource.source : "/usr/local/#{new_resource.servicename}"

    play_service(project_name, home_dir)

    # make template path absolute, if relative
    if new_resource.config_template =~ %r{^/}
      template_path = new_resource.config_template
    else
      template_path = "#{home_dir}/#{new_resource.config_template}"
    end

    # create application.config
    template "#{home_dir}/#{new_resource.config_file}" do
      local true
      owner new_resource.user
      source template_path
      variables(new_resource.config_variables)
      sensitive true
      only_if { ::File.exist?(template_path) }
      notifies :restart, "service[#{new_resource.servicename}]", :delayed
    end
  end
end
