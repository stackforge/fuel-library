# Empty provider implementation, because OVS don't change any
# config files while setup his persistent options
#
Puppet::Type.type(:l23_stored_config).provide(:ovs_centos6) do

  confine :l23_os => :centos6

  has_feature :provider_options

  def exists?
    true
  end

  def create
    true
  end

  def destroy
    true
  end

  def config
    {}
  end

  def config=(value)
    true
  end

end
