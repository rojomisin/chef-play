require 'spec_helper'

SOURCE = 'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.zip'
CONF_VARIABLES = { 'secret' => 'testingonetwothree' }
SERVICENAME = 'sample_service'

describe 'play::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'centos', version: '6.7', step_into: ['play']) do |node|
      node.set['play']['servicename'] = SERVICENAME
      node.set['play']['source'] = SOURCE
      node.set['play']['conf_variables'] = CONF_VARIABLES
    end.converge(described_recipe)
  end
  let(:play_service_template) { chef_run.template('/etc/init.d/sample_service') }

  it 'install unzip package' do
    expect(chef_run).to install_package('unzip')
  end

  it 'install rsync package' do
    expect(chef_run).to install_package('rsync')
  end

  it 'creates play system user' do
    expect(chef_run).to create_user('play')
  end

  it 'unzips local file standalone distribution archive' do
    expect(chef_run).to install_ark('sample_service')
  end

  it 'runs play install action' do
    expect(chef_run).to install_play(SERVICENAME).with(
      source: SOURCE,
      conf_variables: CONF_VARIABLES
    )
  end

  describe 'service' do
    it 'creates pid directory' do
      expect(chef_run).to create_directory('/var/run/play').with(
        user: 'play',
        group: 'play'
      )
    end

    it 'does not install sample_service as a service' do
      expect(chef_run).to_not enable_service(SERVICENAME)
      expect(chef_run).to_not restart_service(SERVICENAME)
      expect(chef_run).to_not stop_service(SERVICENAME)
      expect(chef_run).to_not start_service(SERVICENAME)
    end

    it 'does not register sample_service to start on reboot' do
      expect(chef_run).to_not run_execute('chkconfig sample_service')
    end

    it 'make bin/sample_service file executable' do
      expect(chef_run).to run_execute('chmod +x play-java-sample')
    end

    it 'creates init.d script' do
      expect(chef_run).to create_template('/etc/init.d/sample_service').with(
        user: 'root',
        group: 'root',
        backup: 5
      )
    end

    it 'sends notifications if init.d script created' do
      expect(play_service_template).to notify('service[sample_service]').to(:enable)
      expect(play_service_template).to notify('service[sample_service]').to(:start)
    end

    it 'creates application.conf' do
      expect(chef_run).to_not create_template('/usr/local/sample_service/conf/application.conf').with(
        user: 'play'
      )
    end
  end
end
