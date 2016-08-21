play 'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.zip' do
  conf_local true
  conf_source 'conf/application.conf.erb'
  conf_variables(secret: 'mysecret')
  args %w(-J-Xms128M -J-Xmx512m -J-server)
  path '/opt/play/zip'
end
