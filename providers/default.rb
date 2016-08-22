use_inline_resources

def systype
  return 'systemd' if ::File.exist?('/proc/1/comm') && ::File.open('/proc/1/comm').gets.chomp == 'systemd'
  return 'upstart' if platform?('ubuntu') && ::File.exist?('/sbin/initctl')
  'systemv'
end

def project_name
  return new_resource.project_name if new_resource.project_name
  new_resource.source.match(%r{.*/(.*)-[0-9].*})[1] # http://rubular.com/r/X9PUgZl0UW
rescue
  raise 'Play project_name not defined!'
end

def service_name
  return new_resource.servicename if new_resource.servicename
  project_name
end

def install_dir
  ::File.directory?(new_resource.source) ? new_resource.source : "#{new_resource.path}/#{project_name}-#{version}"
end

def home_dir
  "#{new_resource.path}/#{service_name}"
end

def pid_dir
  "/var/run/#{service_name}"
end

def play_exec
  "#{home_dir}/bin/#{project_name}"
end

# make path absolute if relative
def conf_path
  ::File.exist?(new_resource.conf_path) ? new_resource.conf_path : "#{home_dir}/#{new_resource.conf_path}"
end

# if local, then make path absolute if relative, else return path
def conf_source
  if new_resource.conf_local
    ::File.exist?(new_resource.conf_source) ? new_resource.conf_source : "#{home_dir}/#{new_resource.conf_source}"
  else
    new_resource.conf_source
  end
end

def usr
  new_resource.user.nil? ? service_name : new_resource.user
end

def grp
  if new_resource.group.nil?
    platform?('windows') ? 'Administrators' : service_name
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

action :install do
  package 'unzip' if zipped?

  user usr do # ~FC021
    comment 'Play Framework User'
    shell '/bin/false'
    password new_resource.password
    system true
    only_if { new_resource.user.nil? }
  end

  group grp do # ~FC021
    members usr
    append true
    only_if { new_resource.group.nil? }
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
    to install_dir
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

  # generate application.conf
  template conf_path do
    local new_resource.conf_local
    cookbook new_resource.conf_cookbook if new_resource.conf_cookbook
    owner usr
    group grp
    mode '0600'
    source conf_source
    variables(new_resource.conf_variables)
    sensitive new_resource.sensitive
    not_if { new_resource.conf_cookbook.nil? && !new_resource.conf_local }
    notifies :restart, "service[#{service_name}]"
  end

  vars = {
    name: service_name,
    home: home_dir,
    exec: play_exec,
    args: new_resource.args.join(' '),
    pid_dir: pid_dir,
    user: usr,
    group: grp,
    config: conf_path
  }

  case systype
  when 'systemd'
    template "/etc/systemd/system/#{service_name}.service" do
      source 'systemd.erb'
      cookbook 'play'
      variables vars
      mode '0755'
      notifies(:restart, "service[#{service_name}]")
    end
  when 'upstart'
    template "/etc/init/#{service_name}.conf" do
      source 'upstart.erb'
      cookbook 'play'
      variables vars
      mode '0644'
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
      source 'systemv.erb'
      mode '0755'
      variables vars
      notifies(:restart, "service[#{service_name}]")
    end
  end unless platform?('windows')

  service service_name do
    action :enable
  end
end
