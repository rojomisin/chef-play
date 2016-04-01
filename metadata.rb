name 'play'
maintainer 'Dennis Hoer'
maintainer_email 'dennis.hoer@gmail.com'
license 'MIT'
description 'Installs/Configures Play distribution binary as a service.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.2'

supports 'centos'
supports 'redhat'
supports 'ubuntu'

depends 'ark', '~> 1.0'

source_url 'https://github.com/dhoer/chef-play' if respond_to?(:source_url)
issues_url 'https://github.com/dhoer/chef-play/issues' if respond_to?(:issues_url)
