actions :install
default_action :install

attribute :source, kind_of: String, name_attribute: true
attribute :checksum, kind_of: [String, NilClass]
attribute :user, kind_of: [String, NilClass]
attribute :group, kind_of: [String, NilClass]
attribute :password, kind_of: [String, NilClass]
attribute :project_name, kind_of: [String, NilClass]
attribute :servicename, kind_of: [String, NilClass]
attribute :args, kind_of: [Array, NilClass], default: []
attribute :path, kind_of: String, default: lazy { node['play']['path'] }
attribute :conf_cookbook, kind_of: String, default: lazy { node['play']['conf_cookbook'] }
attribute :conf_source, kind_of: String, default: lazy { node['play']['conf_source'] }
attribute :conf_variables, kind_of: Hash, default: lazy { node['play']['conf_variables'] }
attribute :conf_path, kind_of: String, default: lazy { node['play']['conf_path'] }

# attribute :conf_variables, kind_of: [Hash, NilClass], default: {}
# attribute :conf_template, kind_of: [String, NilClass], default: 'conf/application.conf.erb'
# attribute :conf_path, kind_of: String, default: 'conf/application.conf'
# attribute :pid_dir, kind_of: String, default: '/var/run/play'
