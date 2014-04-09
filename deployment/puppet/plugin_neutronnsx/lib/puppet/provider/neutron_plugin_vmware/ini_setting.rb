Puppet::Type.type(:ini_setting)#.providers

Puppet::Type.type(:neutron_plugin_vmware).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  def section
    resource[:name].split('/', 2).first
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def separator
    '='
  end

  def file_path
    '/etc/neutron/plugins/vmware/nsx.ini'
  end

end

