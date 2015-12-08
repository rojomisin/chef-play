actions :install
default_action :install

attribute :servicename, kind_of: String, name_attribute: true
attribute :source, kind_of: String, required: true
attribute :checksum, kind_of: [String, NilClass], required: false
attribute :project_name, kind_of: [String, NilClass], required: false
attribute :version, kind_of: [String, NilClass], required: false, default: nil
attribute :user, kind_of: String, default: lazy { node['play']['user'] }
attribute :args, kind_of: [Array, NilClass], default: lazy { node['play']['args'] }
attribute :config_variables, kind_of: [Hash, NilClass], default: lazy { node['play']['config_variables'] }
attribute :config_file, kind_of: String, default: lazy { node['play']['config_file'] }
attribute :config_template, kind_of: String, default: lazy { node['play']['config_template'] }
attribute :pid_dir, kind_of: String, default: lazy { node['play']['pid_dir'] }
