require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'dist zip' do
  describe file('/tmp/kitchen/cache/sample_service-1.0.zip') do
    it { should be_file }
  end

  describe user('play') do
    it { should exist }
    it { should belong_to_group 'play' }
  end

  describe file('/usr/local/sample_service-1.0') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'root' }
  end

  describe file('/usr/local/sample_service') do
    it { should be_linked_to '/usr/local/sample_service-1.0' }
    it { should be_mode 777 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/usr/local/sample_service/bin/play-java-sample') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'root' }
  end

  describe file('/usr/local/sample_service/conf/application.conf') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'root' }
    its(:content) { should match(/play.crypto.secret = "mysecret"/) }
  end

  describe file('/var/run/play/sample_service.pid') do
    it { should be_file }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
  end

  describe file('/etc/init.d/sample_service') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match(%r{PLAY_DIST_HOME="/usr/local/sample_service"}) }
    its(:content) { should match(%r{PLAY="\$\{PLAY_DIST_HOME\}/bin/play-java-sample"}) }
    its(:content) { should match(/USER="play"/) }
    its(:content) { should match(%r{PID_PATH="/var/run/play"}) }
    its(:content) { should match(%r{PID_FILE="\$\{PID_PATH\}/sample_service.pid"}) }
    its(:content) { should match(%r{CONFIG_FILE="/usr/local/sample_service/conf/application.conf"}) }
    its(:content) { should match(/APP_ARGS="-Dhttp\.port=8080 -J-Xms128M -J-Xmx512m -J-server"/) }
    its(:content) { should match(%r{su -s /bin/sh \$\{USER\} -c "\( \$\{PLAY\} -Dpidfile\.path=\$\{PID_FILE\}}) }
    its(:content) { should match(/-Dconfig\.file=\$\{CONFIG_FILE\} \$\{APP_ARGS\} &\ \)/) }
  end

  describe service('sample_service') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8080) do
    it { should be_listening }
  end

  describe command('wget -O - localhost:8080') do
    its(:stdout) { should match(%r{<h1>Your new application is ready.<\/h1>}) }
  end
end

describe 'dist tar.gz' do
  describe file('/tmp/kitchen/cache/sample_service2-1.0.tgz') do
    it { should be_file }
  end

  describe user('play') do
    it { should exist }
    it { should belong_to_group 'play' }
  end

  describe file('/usr/local/sample_service2-1.0') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'root' }
  end

  describe file('/usr/local/sample_service2') do
    it { should be_linked_to '/usr/local/sample_service2-1.0' }
    it { should be_mode 777 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/usr/local/sample_service2/bin/play-java-sample') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'root' }
  end

  describe file('/usr/local/sample_service2/conf/application.conf') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'root' }
    its(:content) { should match(/play.crypto.secret = "testingonetwothree"/) }
  end

  describe file('/var/run/play/sample_service2.pid') do
    it { should be_file }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
  end

  describe file('/etc/init.d/sample_service2') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match(%r{PLAY_DIST_HOME="/usr/local/sample_service2"}) }
    its(:content) { should match(%r{PLAY="\$\{PLAY_DIST_HOME\}/bin/play-java-sample"}) }
    its(:content) { should match(/USER="play"/) }
    its(:content) { should match(%r{PID_PATH="/var/run/play"}) }
    its(:content) { should match(%r{PID_FILE="\$\{PID_PATH\}/sample_service2.pid"}) }
    its(:content) { should match(%r{CONFIG_FILE="/usr/local/sample_service2/conf/application.conf"}) }
    its(:content) { should match(/APP_ARGS=""/) }
    its(:content) { should match(%r{su -s /bin/sh \$\{USER\} -c "\( \$\{PLAY\} -Dpidfile\.path=\$\{PID_FILE\}}) }
    its(:content) { should match(/-Dconfig\.file=\$\{CONFIG_FILE\} \$\{APP_ARGS\} &\ \)/) }
  end

  describe service('sample_service2') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(9000) do
    it { should be_listening }
  end

  describe command('wget -O - localhost:9000') do
    its(:stdout) { should match(%r{<h1>Your new application is ready.<\/h1>}) }
  end
end

describe 'dist tar.gz using default application.conf' do
  describe file('/tmp/kitchen/cache/sample_service3-1.0.tgz') do
    it { should be_file }
  end

  describe user('play') do
    it { should exist }
    it { should belong_to_group 'play' }
  end

  describe file('/usr/local/sample_service3-1.0') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'root' }
  end

  describe file('/usr/local/sample_service3') do
    it { should be_linked_to '/usr/local/sample_service3-1.0' }
    it { should be_mode 777 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/usr/local/sample_service3/bin/play-java-sample') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'root' }
  end

  describe file('/usr/local/sample_service3/conf/application.conf') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'root' }
    its(:content) { should match(/play.crypto.secret = "changeme"/) }
  end

  # describe file('/var/run/play/sample_service3.pid') do
  #   it { should be_file }
  #   it { should be_owned_by 'play' }
  #   it { should be_grouped_into 'play' }
  # end

  describe file('/etc/init.d/sample_service3') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match(%r{PLAY_DIST_HOME="/usr/local/sample_service3"}) }
    its(:content) { should match(%r{PLAY="\$\{PLAY_DIST_HOME\}/bin/play-java-sample"}) }
    its(:content) { should match(/USER="play"/) }
    its(:content) { should match(%r{PID_PATH="/var/run/play"}) }
    its(:content) { should match(%r{PID_FILE="\$\{PID_PATH\}/sample_service3.pid"}) }
    its(:content) { should match(%r{CONFIG_FILE="/usr/local/sample_service3/conf/application.conf"}) }
    its(:content) { should match(/APP_ARGS="-Dhttp.port=9001 -J-Xms128M -J-Xmx512m -J-server"/) }
    its(:content) { should match(%r{su -s /bin/sh \$\{USER\} -c "\( \$\{PLAY\} -Dpidfile.path=\$\{PID_FILE\}}) }
    its(:content) { should match(/-Dconfig\.file=\$\{CONFIG_FILE\} \$\{APP_ARGS\} &\ \)/) }
  end

  # describe service('sample_service3') do
  #   it { should be_enabled }
  #   it { should be_running }
  # end
  #
  # describe port(9001) do
  #   it { should be_listening }
  # end
  #
  # describe command('wget -O - localhost:9001') do
  #   its(:stdout) { should match(%r{<h1>Your new application is ready.<\/h1>}) }
  # end
end
