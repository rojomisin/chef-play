include_recipe 'java_se'

# install zip file as sample_service on port 8080
include_recipe 'play'

# install tarball as sample_service2 on default port 9000
play 'sample_service2' do
  source 'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.tgz'
  conf_variables(
    secret: 'testingonetwothree'
  )
  action :install
end
