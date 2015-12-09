play node['play']['servicename'] do
  source node['play']['source']
  checksum node['play']['checksum'] if node['play']['checksum']
  project_name node['play']['project_name'] if node['play']['project_name']
  version node['play']['version'] if node['play']['version']
  user node['play']['user']
  args node['play']['args']
  conf_variables node['play']['conf_variables']
  conf_template node['play']['conf_template']
  conf_path node['play']['conf_path']
  pid_dir node['play']['pid_dir']
  action :install
end
