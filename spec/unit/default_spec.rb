require 'spec_helper'

SOURCE = 'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.zip'.freeze

describe 'play_test::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '7.0', step_into: ['play'], file_cache_path: CACHE
    ).converge(described_recipe)
  end
  # let(:play_service_template) { chef_run.template('/etc/init.d/sample_service') }

  it 'installs play app' do
    expect(chef_run).to install_play(SOURCE).with(
      conf_variables:  { secret: 'mysecret' }
    )
  end

  it 'installs unzip package' do
    expect(chef_run).to install_package('unzip')
  end

  it 'creates group' do
    expect(chef_run).to create_group('play')
  end

  it 'creates user' do
    expect(chef_run).to create_user('play')
  end

  it 'creates path' do
    expect(chef_run).to create_directory('/opt/play')
  end

  it 'downloads app' do
    expect(chef_run).to create_remote_file("#{CACHE}/play-java-sample-1.0.zip")
  end

  it 'verifies executable exists' do
    expect(chef_run).to run_ruby_block('verify executable exists')
  end

  #
  #   it 'does not install sample_service as a service' do
  #     expect(chef_run).to_not enable_service(SERVICENAME)
  #     expect(chef_run).to_not restart_service(SERVICENAME)
  #     expect(chef_run).to_not stop_service(SERVICENAME)
  #     expect(chef_run).to_not start_service(SERVICENAME)
  #   end
  #
  #   it 'does not register sample_service to start on reboot' do
  #     expect(chef_run).to_not run_execute('chkconfig sample_service')
  #   end
  #
  it 'makes play script executable' do
    expect(chef_run).to run_execute('make play script executable')
  end
  #
  #   it 'creates init.d script' do
  #     expect(chef_run).to create_template('/etc/init.d/sample_service').with(
  #       user: 'root',
  #       group: 'root',
  #       backup: 5
  #     )
  #   end
  #
  #   it 'sends notifications if init.d script created' do
  #     expect(play_service_template).to notify('service[sample_service]').to(:enable)
  #     expect(play_service_template).to notify('service[sample_service]').to(:start)
  #   end
  #
  #   it 'creates application.conf' do
  #     expect(chef_run).to create_template('/usr/local/sample_service/conf/application.conf').with(
  #       user: 'play'
  #     )
  #   end
  # end
end
