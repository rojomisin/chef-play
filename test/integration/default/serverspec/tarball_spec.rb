require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'dist tgz' do
  # describe file('/opt/kitchen/cache/play-java-sample-1.0.tgz') do
  #   it { should be_file }
  # end

  describe user('play') do
    it { should exist }
    it { should belong_to_group 'play' }
  end

  describe file('/opt/play/tar/play-java-sample-1.0') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
  end

  describe file('/opt/play/tar/play-java-sample-tar') do
    it { should be_linked_to '/opt/play/tar/play-java-sample-1.0' }
    it { should be_mode 777 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
  end

  describe file('/opt/play/tar/play-java-sample-tar/bin/play-java-sample') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
  end

  describe file('/opt/play/tar/play-java-sample-tar/conf/application.conf') do
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
    its(:content) { should match(/play.crypto.secret = "mysecret"/) }
  end

  describe file('/var/run/play-java-sample-tar/play.pid') do
    it { should be_file }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
  end

  if (os[:family] == 'redhat' && os[:release].split('.')[0].to_i < 7) ||
     (os[:family] == 'ubuntu' && os[:release].split('.')[0].to_i < 15)
    describe file('/etc/init.d/play-java-sample-tar') do # systemv
      it { should be_file }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      # its(:content) { should match(%r{PLAY_DIST_HOME="/local/sample_service"}) }
      # its(:content) { should match(%r{PLAY="\$\{PLAY_DIST_HOME\}/bin/play-java-sample"}) }
      # its(:content) { should match(/USER="play"/) }
      # its(:content) { should match(%r{PID_PATH="/var/run/play"}) }
      # its(:content) { should match(%r{PID_FILE="\$\{PID_PATH\}/sample_service.pid"}) }
      # its(:content) { should match(%r{CONFIG_FILE="/local/sample_service/conf/application.conf"}) }
      # its(:content) { should match(/APP_ARGS="-Dhttp\.port=8080 -J-Xms128M -J-Xmx512m -J-server"/) }
      # its(:content) { should match(%r{su -s /bin/sh \$\{USER\} -c "\( \$\{PLAY\} -Dpidfile\.path=\$\{PID_FILE\}}) }
      # its(:content) { should match(/-Dconfig\.file=\$\{CONFIG_FILE\} \$\{APP_ARGS\} &\ \)/) }
    end
  else # systemd
    describe file('/etc/systemd/system/play-java-sample-tar.service') do
      it { should be_file }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its(:content) { should match(/Description=Play play-java-sample-tar service/) }
      its(:content) { should match(%r{PIDFile=/var/run/play-java-sample-tar/play.pid}) }
      its(:content) { should match(%r{WorkingDirectory=/opt/play/tar/play-java-sample-tar}) }
      its(:content) { should match(/User=play/) }
      its(:content) { should match(/Group=play/) }
      its(:content) { should match(%r{ExecStartPre=/bin/mkdir -p /var/run/play-java-sample-tar}) }
      its(:content) { should match(%r{ExecStartPre=/bin/chown -R play:play /var/run/play-java-sample-tar}) }
      its(:content) do
        should match(%r{ExecStart=/opt/play/tar/play-java-sample-tar/bin/play-java-sample \
-Dpidfile.path=/var/run/play-java-sample-tar/play.pid \
-Dconfig.file=/opt/play/tar/play-java-sample-tar/conf/application.conf \
-Dhttp.port=8080 -J-Xms128M -J-Xmx512m -J-server})
      end
      its(:content) { should match(%r{ExecStopPost=/bin/rm -f /var/run/play-java-sample-tar/play.pid}) }
    end
  end

  describe service('play-java-sample-tar') do
    it { should be_enabled } unless os[:family] == 'debian'
    it { should be_running }
  end

  describe port(9000), if: !%w(redhat fedora).include?(os[:family]) do
    it { should be_listening }
  end

  describe command('wget -O - localhost:8080') do
    its(:stdout) { should match(%r{<h1>Your new application is ready.<\/h1>}) }
  end
end
