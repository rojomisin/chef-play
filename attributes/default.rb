default['play']['path'] = platform?('windows') ? "#{ENV['SYSTEMDRIVE']}/play" : '/opt/play'
default['play']['sensitive'] = true
