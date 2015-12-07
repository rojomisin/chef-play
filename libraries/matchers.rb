if defined?(ChefSpec)
  def install_play(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:play, :install, resource_name)
  end
end
