def whyrun_supported?
  true
end

use_inline_resources

def systype
  return 'systemd' if ::File.exist?('/proc/1/comm') && ::File.open('/proc/1/comm').gets.chomp == 'systemd'
  'sysvinit'
end

def project_name
  return new_resource.project_name if new_resource.project_name
  new_resource.source.match(%r{.*/(.*)-[0-9].*})[1] # http://rubular.com/r/X9PUgZl0UW
rescue
  raise 'Play project_name not defined!'
end

def pid_dir
  "/var/run/#{service_name}"
end

def play_exec
  "#{home_dir}/bin/#{project_name}"
end

def play_configuration(home_dir, conf_path)
  # make template path absolute, if relative
  template_path =
    new_resource.conf_template =~ %r{^/} ? new_resource.conf_template : "#{home_dir}/#{new_resource.conf_template}"

  ruby_block 'verify conf_template can be run' do # ~FC021
    block do
      raise("Play conf_template #{template_path} not found!")
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
    notifies :restart, "service[#{service_name}]", :delayed
  end
end

def install_dir
  ::File.directory?(new_resource.source) ? new_resource.source : "#{new_resource.path}/#{project_name}-#{version}"
end

def home_dir
  "#{new_resource.path}/#{service_name}"
end

def conf_path
  new_resource.conf_path =~ %r{^/} ? new_resource.conf_path : "#{home_dir}/#{new_resource.conf_path}"
end

def usr
  new_resource.user.nil? ? 'play' : new_resource.user
end

def grp
  if new_resource.group.nil?
    platform?('windows') ? 'Administrators' : 'play'
  else
    new_resource.group
  end
end

def filename(src = new_resource.source)
  src.slice(src.rindex('/') + 1, src.size)
end

def version(src = new_resource.source)
  src.match(/-([\d|.(-SNAPSHOT)]*)[-|.]/)[1] # http://rubular.com/r/KN2ILF3mj3
end

def zipped?
  filename.include?('.zip')
end

def service_name
  return new_resource.servicename if new_resource.servicename
  project_name
end

action :install do
  converge_by("install play #{service_name}") do
    package 'unzip' if zipped?

    group grp do # ~FC021
      system true
      only_if { grp == 'play' }
    end

    user usr do # ~FC021
      comment 'Play Framework User'
      home new_resource.path
      shell '/bin/false'
      password new_resource.password
      gid grp
      system true
      only_if { new_resource.user.nil? }
    end

    directory new_resource.path do
      recursive true
      owner usr
      group grp
    end

    source_filename = filename(new_resource.source)
    cached_file = ::File.join(Chef::Config[:file_cache_path], source_filename)

    remote_file cached_file do
      source new_resource.source
      checksum new_resource.checksum unless new_resource.checksum.nil?
      not_if { ::File.directory?(new_resource.source) }
      notifies(:run, "execute[untar #{cached_file}]", :immediately) unless zipped?
      notifies(:run, "execute[unzip #{cached_file}]", :immediately) if zipped?
    end

    execute "untar #{cached_file}" do
      command "tar -xzf #{cached_file} && chown -R #{usr}:#{grp} *"
      cwd new_resource.path
      action :nothing
      notifies(:restart, "service[#{service_name}]")
    end

    execute "unzip #{cached_file}" do
      command "unzip #{cached_file} && chown -R #{usr}:#{grp} *"
      cwd new_resource.path
      action :nothing
      notifies(:restart, "service[#{service_name}]")
    end

    link home_dir do
      to  install_dir
      owner usr
      group grp
      notifies(:restart, "service[#{service_name}]")
    end

    ruby_block 'verify executable exists' do
      block do
        raise "Play executable #{play_exec} not found!"
      end
      not_if { ::File.exist?(play_exec) }
    end

    execute 'make play script executable' do
      command "chmod +x #{play_exec}"
      only_if { zipped? }
    end

    case systype
    when 'systemd'
      template "/etc/systemd/system/#{service_name}.service" do
        source 'systemd.erb'
        cookbook 'play'
        variables(
          name: service_name,
          home: home_dir,
          exec: play_exec,
          args: new_resource.args.join(' '),
          pid_dir: pid_dir,
          user: usr,
          group: grp
        )
        notifies(:restart, "service[#{service_name}]")
      end
    else
      directory pid_dir do
        recursive true
        owner usr
        group grp
      end

      template "/etc/init.d/#{service_name}" do
        cookbook 'play'
        source "#{node['platform_family']}.init.erb"
        mode 0o755
        variables(
          servicename: service_name,
          source: home_dir,
          executable: project_name,
          user: new_resource.user,
          pid_path: pid_dir,
          conf_path: conf_path,
          args: new_resource.args.join(' ')
        )
        notifies :enable, "service[#{service_name}]", :immediately
        notifies :start, "service[#{service_name}]", :immediately
      end
    end unless platform?('windows')

    service service_name do
      action :enable
    end
  end
end
