# Play Cookbook

[![Cookbook Version](http://img.shields.io/cookbook/v/play.svg?style=flat-square)][cookbook]
[![Build Status](http://img.shields.io/travis/dhoer/chef-play.svg?style=flat-square)][travis]

[cookbook]: https://supermarket.chef.io/cookbooks/play
[travis]: https://travis-ci.org/dhoer/chef-play

Installs Play 2.2+ 
[standalone distribution](https://www.playframework.com/documentation/2.5.x/Deploying#Using-the-dist-task) 
(tar.gz, tgz, or zip) and configures it as a service.

## Requirements

- Java (must be installed outside this cookbook)
- Chef 12+

### Platforms

- CentOS, Red Hat, Fedora
- Debian, Ubuntu

# Usage

Installs Play 2.2+ standalone distribution and configures it as a systemd or systemv service. The servicename will 
default to the project_name of the distribution if none is provided. The application.conf file can be 
created/overwritten with a template 
[included in the distribution](https://github.com/dhoer/chef-play/wiki/Creating-a-local-template) or by an external 
template from another cookbook.  For Linux users, zip files do not retain Linux file permissions so when the file is 
expanded the start script will be set as an executable. The pid path for Linux users will default to 
`/var/run/#{servicename}/play.pid`.

### Attributes

* `source` - URI to archive (tar.gz, tgz, or zip) or directory path to exploded archive. Defaults to resource name.
* `checksum` - The SHA-256 checksum of the file. Use to prevent resource from re-downloading remote file. Default `nil`. 
* `project_name` - Used to identify start script executable.  Derives project_name from standalone distribution 
filename when nil. Default `nil`
* `servicename` - Service name to run as.  Defaults to project_name when nil. Default `nil`.
* `conf_cookbook` -  Cookbook containing application conf template to use. Default `nil`.
* `conf_local` -  Load application conf template from a local path. Default `false`.
* `conf_source` -  Path to configuration template.  Local path can be relative, or if the template file is outside 
standalone distribution, absolute. Default `nil`. 
* `conf_path` - Path to application configuration file. Path can be relative, or if the config file is outside 
standalone distribution, absolute. Default `conf/application.conf`. 
* `conf_variables` - Hash of application configuration variables required by application conf template. Default `{}`.
* `args` - Array of additional configuration arguments.  Default `[]`. 
* `user` - Creates a user using servicename when nil or uses value passed in. Default `nil`.
* `group` - Creates a group using servicename when nil or uses value passed in. Default `nil`.
* `path` - Path to install standalone distribution. Default `/opt/play`. 
* `sensitive` - Suppress output. Default `true`.

### Examples

#### Install distribution as service and generate application.conf from template included in the distribution

```ruby
play 'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.zip' do
  conf_local true 
  conf_source 'conf/application.conf.erb'
  conf_variables(
    secret: 'abcdefghijk',
    langs: %w(en fr)
  )
  args([
    '-Dhttp.port=8080',
    '-J-Xms128m',
    '-J-Xmx512m',
    '-J-server'
  ])
  action :install
end
```

The application configuration defined in conf_path will be created/replaced by template defined in conf_source.

#### Install a standalone distribution from local file as service and generate application.conf from another cookbook

```ruby
play 'file:///var/chef/cache/myapp-1.0.0.zip' do
  conf_cookbook 'mycookbook'
  conf_source 'application.conf.erb'
  conf_variables(
    secret: 'abcdefghijk',
    langs: %w(en fr)
  )
  args([
    '-Dhttp.port=8080',
    '-J-Xms128m',
    '-J-Xmx512m',
    '-J-server'
  ])
  action :install
end
```

The application configuration defined in conf_path will be created/replaced by template defined in conf_source.

#### Install exploded standalone distribution as service and don't generate application.conf from template

```ruby
play '/opt/myapp' do
   args([
    '-Dhttp.port=8080',
    '-J-Xms128m',
    '-J-Xmx512m',
    '-J-server'
  ])
  action :install
end
```

Since both conf_local false and conf_cookbook nil, the application configuration defined in conf_path will be used.

## ChefSpec Matchers

This cookbook includes custom [ChefSpec](https://github.com/sethvargo/chefspec) matchers you can use to test your 
own cookbooks.

Example Matcher Usage

```ruby
expect(chef_run).to install_play(
  'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.zip'
).with(
  conf_local true
  conf_source 'conf/application.conf.erb'
  conf_path 'conf/application.conf'
  conf_variables: {
    secret: 'abcdefghijk'
    langs: %w(en fr)
  }
  args: [
    '-Dhttp.port=8080',
    '-J-Xms128m',
    '-J-Xmx512m',
    '-J-server' 
  ]
)
```
 
Cookbook Matchers

- install_play(resource_name)

## Getting Help

- Ask specific questions on [Stack Overflow](http://stackoverflow.com/questions/tagged/playframework+chef).
- Report bugs and discuss potential features in [Github issues](https://github.com/dhoer/chef-play/issues).

## Contributing

Please refer to [CONTRIBUTING](https://github.com/dhoer/chef-play/blob/master/CONTRIBUTING.md).

## License

MIT - see the accompanying [LICENSE](https://github.com/dhoer/chef-play/blob/master/LICENSE.md) file for 
details.
