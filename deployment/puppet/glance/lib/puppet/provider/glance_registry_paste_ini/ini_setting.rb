Puppet::Type.type(:glance_registry_paste_ini).provide(
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

  def self.file_path
    '/etc/glance/glance-registry-paste.ini'
  end

  # added for backwards compatibility with older versions of inifile
  def file_path
    self.class.file_path
  end

end
