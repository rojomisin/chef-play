actions :install
default_action :install

attribute :servicename, kind_of: String, name_attribute: true
attribute :source, kind_of: String, required: true
attribute :checksum, kind_of: [String, NilClass], default: nil
attribute :project_name, kind_of: [String, NilClass], default: nil
attribute :version, kind_of: [String, NilClass], default: nil
attribute :user, kind_of: String, default: 'play'
attribute :args, kind_of: [Array, NilClass], default: []
attribute :conf_variables, kind_of: [Hash, NilClass], default: {}
attribute :conf_template, kind_of: [String, NilClass], default: 'conf/application.conf.erb'
attribute :conf_path, kind_of: String, default: 'conf/application.conf'
attribute :pid_dir, kind_of: String, default: '/var/run/play'
