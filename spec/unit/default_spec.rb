require 'spec_helper'

describe 'play_test::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '7.0', step_into: ['play'], file_cache_path: CACHE
    ).converge(described_recipe)
  end
  let(:play_service_template) { chef_run.template('/etc/init.d/play-java-sample') }

  it 'installs play app' do
    expect(chef_run).to install_play(
      'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.zip'
    ).with(
      conf_variables:  { secret: 'mysecret' }
    )
  end

  it 'installs unzip package' do
    expect(chef_run).to install_package('unzip')
  end

  it 'creates user' do
    expect(chef_run).to create_user('play')
  end

  it 'creates group' do
    expect(chef_run).to create_group('play')
  end

  it 'creates path' do
    expect(chef_run).to create_directory('/opt/play/zip')
  end

  it 'downloads app' do
    expect(chef_run).to create_remote_file("#{CACHE}/play-java-sample-1.0.zip")
  end

  it 'does not untar zip' do
    expect(chef_run).to_not run_execute("untar #{CACHE}/play-java-sample-1.0.zip")
  end

  it 'unzips zip' do
    expect(chef_run).to_not run_execute("unzip #{CACHE}/play-java-sample-1.0.zip")
  end

  it 'creates link' do
    expect(chef_run).to create_link('/opt/play/zip/play-java-sample')
  end

  it 'verifies executable exists' do
    expect(chef_run).to run_ruby_block('verify executable exists')
  end

  it 'makes play script executable' do
    expect(chef_run).to run_execute('make play script executable')
  end

  it 'configures application.conf' do
    expect(chef_run).to create_template('/opt/play/zip/play-java-sample/conf/application.conf')
  end

  it 'creates pid dir' do
    expect(chef_run).to create_directory('/var/run/play-java-sample')
  end

  it 'restarts service' do
    expect(play_service_template).to notify('service[play-java-sample]').to(:restart)
  end

  it 'creates service script' do
    expect(chef_run).to create_template('/etc/init.d/play-java-sample')
  end

  it 'enables service script' do
    expect(chef_run).to enable_service('play-java-sample')
  end
end
