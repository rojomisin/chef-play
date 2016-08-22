require 'serverspec'

# Required by serverspec
set :backend, :exec

def systype
  return 'systemd' if ::File.exist?('/proc/1/comm') && ::File.open('/proc/1/comm').gets.chomp == 'systemd'
  return 'upstart' if platform?('ubuntu') && ::File.exist?('/sbin/initctl')
  'systemv'
end

describe 'dist zip' do
  # describe file('/opt/kitchen/cache/play-java-sample-1.0.zip') do
  #   it { should be_file }
  # end

  describe user('play-java-sample') do
    it { should exist }
    it { should belong_to_group 'play-java-sample' }
  end

  describe file('/opt/play/zip/play-java-sample-1.0') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'play-java-sample' }
    it { should be_grouped_into 'play-java-sample' }
  end

  describe file('/opt/play/zip/play-java-sample') do
    it { should be_linked_to '/opt/play/zip/play-java-sample-1.0' }
    it { should be_mode 777 }
    it { should be_owned_by 'play-java-sample' }
    it { should be_grouped_into 'play-java-sample' }
  end

  describe file('/opt/play/zip/play-java-sample/bin/play-java-sample') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'play-java-sample' }
    it { should be_grouped_into 'play-java-sample' }
  end

  describe file('/opt/play/zip/play-java-sample/conf/application.conf') do
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'play-java-sample' }
    it { should be_grouped_into 'play-java-sample' }
    its(:content) { should match(/play.crypto.secret = "mysecret"/) }
  end

  describe file('/var/run/play-java-sample/play.pid') do
    it { should be_file }
    it { should be_owned_by 'play-java-sample' }
    it { should be_grouped_into 'play-java-sample' }
  end

  case systype
  when 'systemd'
    describe file('/etc/systemd/system/play-java-sample.service') do
      it { should be_file }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its(:content) { should match(/Description=Play play-java-sample service/) }
      its(:content) { should match(%r{PIDFile=/var/run/play-java-sample/play.pid}) }
      its(:content) { should match(%r{WorkingDirectory=/opt/play/zip/play-java-sample}) }
      its(:content) { should match(/User=play-java-sample/) }
      its(:content) { should match(/Group=play-java-sample/) }
      its(:content) { should match(%r{ExecStartPre=/bin/mkdir -p /var/run/play-java-sample}) }
      its(:content) do
        should match(
          %r{ExecStartPre=/bin/chown -R play-java-sample:play-java-sample /var/run/play-java-sample}
        )
      end
      its(:content) do
        should match(%r{ExecStart=/opt/play/zip/play-java-sample/bin/play-java-sample \
-Dpidfile.path=/var/run/play-java-sample/play.pid -Dconfig.file=/opt/play/zip/play-java-sample/conf/application.conf \
-J-Xms128M -J-Xmx512m -J-server})
      end
      its(:content) { should match(%r{ExecStopPost=/bin/rm -f /var/run/play-java-sample/play.pid}) }
    end
  when 'upstart'
    describe file('/etc/init/play-java-sample') do
      it { should be_file }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its(:content) { should match(/description "Play play-java-sample service"/) }
      its(:content) do
        should match(%r{\[ -d /var/run/play-java-sample/play.pid \] || install -m 755 \
-o /var/run/play-java-sample -g /var/run/play-java-sample -d /var/run/play-java-sample/play.pid})
      end
      its(:content) { should match(%r{chdir /opt/play/zip/play-java-sample}) }
      its(:content) do
        should match(%r{exec sudo -u /var/run/play-java-sample /var/run/play-java-sample \
-Dpidfile.path=/var/run/play-java-sample/play.pid -Dconfig.file=/opt/play/zip/play-java-sample/conf/application.conf \
-J-Xms128M -J-Xmx512m -J-server})
      end
    end
  else
    describe file('/etc/init.d/play-java-sample') do
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
  end

  describe service('play-java-sample') do
    it { should be_enabled } unless os[:family] == 'debian'
    it { should be_running }
  end

  describe port(9000), if: !%w(redhat fedora).include?(os[:family]) do
    it { should be_listening }
  end

  describe command('wget -O - localhost:9000') do
    its(:stdout) { should match(%r{<h1>Your new application is ready.<\/h1>}) }
  end
end
