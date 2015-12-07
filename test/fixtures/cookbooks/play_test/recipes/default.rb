include_recipe 'java_se'
include_recipe 'logrotate'

logrotate_app 'sample_service' do
  cookbook 'logrotate'
  path '/var/log/tomcat/myapp.log'
  frequency 'daily'
  rotate 30
  create '644 root adm'
end

play 'sample_service' do
  source 'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.zip'
  config_variables(
    secret: 'testingonetwothree'
  )
  action :install
end
