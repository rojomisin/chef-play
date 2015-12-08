name 'play'
maintainer 'Dennis Hoer'
maintainer_email 'dennis.hoer@gmail.com'
license 'MIT'
description 'Installs distribution artifact, created by the dist task (Play 2.2+), as a service.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'

supports 'centos'
supports 'redhat'
supports 'ubuntu'

depends 'ark', '~> 0.9'
