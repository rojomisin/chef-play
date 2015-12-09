actions :install
default_action :install

attribute :servicename, kind_of: String, name_attribute: true
attribute :source, kind_of: String, required: true
attribute :checksum, kind_of: [String, NilClass], default: nil
attribute :project_name, kind_of: [String, NilClass], default: nil
attribute :version, kind_of: [String, NilClass], default: nil
attribute :user, kind_of: String, default: lazy { node['play']['user'] }
attribute :args, kind_of: [Array, NilClass], default: lazy { node['play']['args'] }
attribute :conf_variables, kind_of: [Hash, NilClass], default: lazy { node['play']['conf_variables'] }
attribute :conf_template, kind_of: [String, NilClass], default: lazy { node['play']['conf_template'] }
attribute :conf_path, kind_of: String, required: true, default: lazy { node['play']['conf_path'] }
attribute :pid_dir, kind_of: String, required: true, default: lazy { node['play']['pid_dir'] }
