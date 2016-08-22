require 'chefspec'
require 'chefspec/berkshelf'

CACHE = Chef::Config[:file_cache_path]

at_exit { ChefSpec::Coverage.report! }
