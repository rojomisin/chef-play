default['play']['path'] = platform?('windows') ? "#{ENV['SYSTEMDRIVE']}/play" : '/opt/play'
default['play']['conf_variables'] = {}
default['play']['conf_template'] = 'conf/application.conf.erb'
default['play']['conf_path'] = 'conf/application.conf'
