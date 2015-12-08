include_recipe 'java_se'

play 'sample_service' do
  source 'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.zip'
  config_variables(
    secret: 'testingonetwothree'
  )
  action :install
end
