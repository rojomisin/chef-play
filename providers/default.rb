def whyrun_supported?
  true
end

use_inline_resources

def play_service(home_dir, conf_path)
  project_name = play_project_name

  # create pid directory
  directory new_resource.pid_dir do
    owner new_resource.user
    group new_resource.user
    mode 0755
  end

  # make play script executable
  execute "chmod +x #{project_name}" do
    cwd "#{home_dir}/bin"
  end

  service new_resource.servicename do
    init_command "/etc/init.d/#{new_resource.servicename}"
    supports status: true, start: true, stop: true, restart: true
    action :nothing
  end

  # create play service
  template "/etc/init.d/#{new_resource.servicename}" do
    cookbook 'play'
    source "#{node['platform_family']}.init.erb"
    owner 'root'
    group 'root'
    mode 0755
    variables(
      servicename: new_resource.servicename,
      source: home_dir,
      executable: project_name,
      user: new_resource.user,
      pid_path: new_resource.pid_dir,
      conf_path: conf_path,
      args: new_resource.args.join(' ')
    )
    notifies :enable, "service[#{new_resource.servicename}]", :immediately
    notifies :start, "service[#{new_resource.servicename}]", :immediately
  end
end

def play_configuration(home_dir, conf_path)
  # make template path absolute, if relative
  if new_resource.conf_template =~ %r{^/}
    template_path = new_resource.conf_template
  else
    template_path = "#{home_dir}/#{new_resource.conf_template}"
  end

  ruby_block 'verify conf_template can be run' do # ~FC021
    block do
      fail("Play conf_template #{template_path} not found!")
    end
    only_if { !new_resource.conf_variables.empty? && !::File.exist?(template_path) }
  end

  # generate application.conf
  template conf_path do
    local true
    owner new_resource.user
    source template_path
    variables(new_resource.conf_variables)
    sensitive true
    only_if { !new_resource.conf_variables.empty? }
    notifies :restart, "service[#{new_resource.servicename}]", :delayed
  end
end

def play_project_name
  return new_resource.project_name if new_resource.project_name
  (new_resource.source).match(%r{.*/(.*)-[0-9].*})[1] # http://rubular.com/r/X9PUgZl0UW
end

def play_app_version
  return new_resource.version if new_resource.version
  (new_resource.source).match(/-([\d|.(-SNAPSHOT)]*)[-|.]/)[1] # http://rubular.com/r/KN2ILF3mj3
end

def play_home_dir
  ::File.directory?(new_resource.source) ? new_resource.source : "/usr/local/#{new_resource.servicename}"
end

def play_conf_path(home_dir)
  new_resource.conf_path =~ %r{^/} ? new_resource.conf_path : "#{home_dir}/#{new_resource.conf_path}"
end

action :install do
  converge_by(new_resource) do
    %w(unzip rsync).each do |pkg|
      package "install play #{pkg} package dependency" do
        package_name pkg
      end
    end

    user new_resource.user do
      comment 'play'
      system true
      shell '/bin/false'
    end

    ark new_resource.servicename do # ~FC021
      url new_resource.source
      checksum new_resource.checksum if new_resource.checksum
      version play_app_version
      owner new_resource.user
      not_if { ::File.directory?(new_resource.source) }
    end

    home_dir = play_home_dir
    conf_path = play_conf_path(home_dir)
    play_service(home_dir, conf_path)
    play_configuration(home_dir, conf_path)
  end
end
