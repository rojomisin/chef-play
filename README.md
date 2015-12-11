# Play Cookbook

[![Cookbook Version](http://img.shields.io/cookbook/v/play.svg?style=flat-square)][cookbook]
[![Build Status](http://img.shields.io/travis/dhoer/chef-play.svg?style=flat-square)][travis]

[cookbook]: https://supermarket.chef.io/cookbooks/play
[travis]: https://travis-ci.org/dhoer/chef-play

Installs Play 2.2+ distribution artifact,
[created by the dist or universal:packageZipTarball task](https://www.playframework.com/documentation/2.5.x/Production#Using-the-dist-task), 
and configures it as a service.

It is recommended that you include a `application.conf.erb` template file within the distribution artifact to configure 
environment specific variables like application secret.  
 
To include the .erb file in your distribution artifact, copy `application.conf` file and paste it as 
`application.conf.erb` in the same directory. Then replace the environment specific values with variables. 

For example, replace `play.crypto.secret = "changeme"` with `play.crypto.secret = "<%= @secret %>"` in 
`application.conf.erb` file, then pass the variable and its value using `conf_variables` 
attribute. The variable names in template must match variable names passed into `conf_variables`.
  
So if `application.conf.erb` contained:

```ruby
play.crypto.secret = "<%= @secret %>"
```

And Play recipe was called with:

```ruby
node.set['play']['servicename'] = 'servicename'
node.set['play']['source'] = 'https://example.com/dist/myapp-1.0.0.zip'
node.set['play']['conf_variables'] = { secret: 'abcdefghijk' }
include_recipe 'play'
```

This would then result in creating/replacing `application.conf` file with:

```ruby
play.crypto.secret = "abcdefghijk"
```

Also Note

* Leaving `conf_variable` empty will skip template processing and use configuration defined in `conf_path`
* The `conf_template` path can also be external from distribution artifact 

## Requirements

- Java (must be installed outside this cookbook)
- Chef 11+

### Platforms

- Centos/RedHat
- Ubuntu 

### Cookbooks

- ark

## Usage

See [play_test](https://github.com/dhoer/chef-play/blob/master/test/fixtures/cookbooks/play_test/recipes/default.rb)
cookbook for an example using play cookbook to install distribution artifacts as a service.

### Attributes

The attributes descriptions are for both resource and recipe e.g., `servicename` or `node['play']['servicename']`.

* `servicename` - Service name to run as.  Defaults to name of resource block.
* `source` - URI to archive (zip, tar.gz, or tgz) or directory path to exploded archive. 
* `checksum` - The SHA-256 checksum of the file. Use to prevent resource from re-downloading a file. 
When  local file matches the checksum, the chef-client will not download it.
* `project_name` - Used to identify start script executable.  Defaults to project name derived from standalone 
distribution filename, if not provided.
* `version` - Version of application.  Defaults to version derived from standalone distribution filename, if 
not provided. Not needed if source is a directory.
* `user` - User to run service as.  Default `play`.
* `args` - Array of additional configuration arguments.  Default `[]`. 
* `conf_variables` - Hash of application configuration variables required by .erb template. Leave empty
to not process conf_template and use application configuration defined in conf_path as is.  Default `{}`.
* `conf_template` - Path to configuration template.  Path can be relative, or if the template file is outside dist 
path, absolute.  If template file not found, no template processing will occur. 
Default `conf/application.conf.erb`.
* `conf_path` - Path to application configuration file. Path can be relative, or if the config file is outside 
standalone distribution, absolute. Default `conf/application.conf`.
* `pid_dir` - The pid directory. Default `/var/run/play`.

### Examples

Examples below are using resource, but you can use the default recipe to do the same thing as well.


#### Install a standalone distribution as service from local file and generate application.conf

```ruby
play 'servicename' do
  source 'file:///var/chef/cache/myapp-1.0.0.zip'
  conf_variables(
    secret: 'mysecret'
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

The application configuration defined in conf_path will be created or replaced by template defined in conf_template.

#### Install exploded standalone distribution as service and don't generate application.conf

```ruby
play 'sample_service' do
  source '/var/local/mysample'
  project_name 'sample'
  args([
    '-Dhttp.port=8080',
    '-J-Xms128m',
    '-J-Xmx512m',
    '-J-server'
  ])
  action :install
end
```

Since no conf_variables are passed, the application configuration defined in conf_path will be used.

## ChefSpec Matchers

This cookbook includes custom [ChefSpec](https://github.com/sethvargo/chefspec) matchers you can use to test your 
own cookbooks.

Example Matcher Usage

```ruby
expect(chef_run).to install_play('servicename').with(
  source: 'https://github.com/dhoer/play-java-sample/releases/download/1.0/play-java-sample-1.0.zip',
  conf_variables: {
    secret: 'abcdefghijk'
  }
)
```
      
Cookbook Matchers

- install_play(name)

## Getting Help

- Ask specific questions on [Stack Overflow](http://stackoverflow.com/questions/tagged/chef-play).
- Report bugs and discuss potential features in [Github issues](https://github.com/dhoer/chef-play/issues).

## Contributing

Please refer to [CONTRIBUTING](https://github.com/dhoer/chef-play/blob/master/CONTRIBUTING.md).

## License

MIT - see the accompanying [LICENSE](https://github.com/dhoer/chef-play/blob/master/LICENSE.md) file for 
details.
