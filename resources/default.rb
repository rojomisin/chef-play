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
attribute :conf_cookbook, kind_of: [String, NilClass]
attribute :conf_local, kind_of: [TrueClass, FalseClass], default: false
attribute :conf_source, kind_of: [String, NilClass]
attribute :conf_path, kind_of: String, default: 'conf/application.conf'
attribute :conf_variables, kind_of: Hash, default: {}
attribute :path, kind_of: String, default: lazy { node['play']['path'] }
attribute :sensitive, kind_of: [TrueClass, FalseClass] # , default: true - see initialize below

def initialize(*args)
  super
  # Chef will override sensitive back to its global value, so set default to true in init
  @sensitive = lazy { node['play']['sensitive'] }
end
