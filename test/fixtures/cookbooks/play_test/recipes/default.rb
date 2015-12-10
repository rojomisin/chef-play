include_recipe 'java_se'

# install zip file as sample_service on port 8080 using attributes passed via .kitchen.yml
include_recipe 'play'

# install tarball as sample_service2 on default port 9000
play 'sample_service2' do
  source 'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.tgz'
  conf_variables(
    secret: 'testingonetwothree'
  )
  action :install
end

# install tarball as sample_service3 on port 9001 using provided application.conf
play 'sample_service3' do
  source 'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.tgz'
  args %w(-Dhttp.port=9001 -J-Xms128M -J-Xmx512m -J-server)
  action :install
end
