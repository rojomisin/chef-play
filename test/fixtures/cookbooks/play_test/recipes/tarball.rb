play 'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.tgz' do
  servicename 'play-java-sample-tar'
  conf_cookbook 'play_test'
  conf_source 'application.conf.erb'
  conf_variables(secret: 'mysecret', langs: %w(en fr))
  args %w(-Dhttp.port=8080 -J-Xms128M -J-Xmx512m -J-server)
  path '/opt/play/tar'
end
