require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'dist zip' do
  # describe file('/opt/kitchen/cache/play-java-sample-1.0.zip') do
  #   it { should be_file }
  # end

  describe user('play') do
    it { should exist }
    it { should belong_to_group 'play' }
  end

  describe file('/opt/play/zip/play-java-sample-1.0') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
  end

  describe file('/opt/play/zip/play-java-sample') do
    it { should be_linked_to '/opt/play/zip/play-java-sample-1.0' }
    it { should be_mode 777 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
  end

  describe file('/opt/play/zip/play-java-sample/bin/play-java-sample') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
  end

  describe file('/opt/play/zip/play-java-sample/conf/application.conf') do
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
    its(:content) { should match(/play.crypto.secret = "mysecret"/) }
  end

  describe file('/var/run/play-java-sample/play.pid') do
    it { should be_file }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
  end

  if (os[:family] == 'redhat' && os[:release].split('.')[0].to_i < 7) ||
     (os[:family] == 'ubuntu' && os[:release].split('.')[0].to_i < 15)
    describe file('/etc/init.d/play-java-sample') do
      it { should be_file }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its(:content) { should match(%r{PLAY_DIST_HOME="/local/sample_service"}) }
      its(:content) { should match(%r{PLAY="\$\{PLAY_DIST_HOME\}/bin/play-java-sample"}) }
      its(:content) { should match(/USER="play"/) }
      its(:content) { should match(%r{PID_PATH="/var/run/play"}) }
      its(:content) { should match(%r{PID_FILE="\$\{PID_PATH\}/sample_service.pid"}) }
      its(:content) { should match(%r{CONFIG_FILE="/local/sample_service/conf/application.conf"}) }
      its(:content) { should match(/APP_ARGS="-Dhttp\.port=8080 -J-Xms128M -J-Xmx512m -J-server"/) }
      its(:content) { should match(%r{su -s /bin/sh \$\{USER\} -c "\( \$\{PLAY\} -Dpidfile\.path=\$\{PID_FILE\}}) }
      its(:content) { should match(/-Dconfig\.file=\$\{CONFIG_FILE\} \$\{APP_ARGS\} &\ \)/) }
    end
  else # systemd
    describe file('/etc/systemd/system/play-java-sample.service') do
      it { should be_file }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its(:content) { should match(/Description=Play play-java-sample service/) }
      its(:content) { should match(%r{PIDFile=/var/run/play-java-sample/play.pid}) }
      its(:content) { should match(%r{WorkingDirectory=/opt/play/zip/play-java-sample}) }
      its(:content) { should match(/User=play/) }
      its(:content) { should match(/Group=play/) }
      its(:content) { should match(%r{ExecStartPre=/bin/mkdir /var/run/play-java-sample}) }
      its(:content) { should match(%r{ExecStartPre=/bin/chown -R play:play /var/run/play-java-sample}) }
      its(:content) do
        should match(%r{ExecStart=/opt/play/zip/play-java-sample/bin/play-java-sample \
-Dpidfile.path=/var/run/play-java-sample/play.pid -Dconfig.file=/opt/play/zip/play-java-sample/conf/application.conf \
-J-Xms128M -J-Xmx512m -J-server})
      end
      its(:content) { should match(%r{ExecStopPost=/bin/rm -f /var/run/play-java-sample/play.pid}) }
    end
  end

  describe service('play-java-sample') do
    it { should be_enabled } unless os[:family] == 'debian'
    it { should be_running }
  end

  describe port(9000) do
    it { should be_listening }
  end

  describe command('wget -O - localhost:9000') do
    its(:stdout) { should match(%r{<h1>Your new application is ready.<\/h1>}) }
    its(:stderr) { should match(/dfsadf/) }
  end

  describe command('systemctl restart play-java-sample') do
    its(:stdout) { should match(/dfsadf/) }
    its(:stderr) { should match(/dfsadf/) }
  end
  describe command('journalctl -xe') do
    its(:stdout) { should match(/dfsadf/) }
    its(:stderr) { should match(/dfsadf/) }
  end
end
