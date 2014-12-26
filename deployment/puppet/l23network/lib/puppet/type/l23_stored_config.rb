# type for managing persistent interface config options
# Inspired by puppet-network module. Adrien, thanks.

require 'puppet/property/boolean'

Puppet::Type.newtype(:l23_stored_config) do
  @doc = "Manage lines in interface config file"
  desc @doc

  feature :provider_options, <<-EOD
    The provider can accept a hash of arbitrary options. The semantics of
    these options will depend on the provider.
  EOD

  ensurable

  newparam(:name) do
    isnamevar
    desc "The name of the physical or logical network device"
  end

  newproperty(:method) do
    desc "The method for determining an IP address for the interface"
    # static -- assign IP address in config
    # manual -- UP interface without IP address
    newvalues(:static, :manual, :dhcp, :loopback)
    aliasvalue(:none, :manual)
    defaultto :manual
  end

  # newproperty(:port_type) do
  #   desc "port_type fake RO property"
  # end

  newproperty(:if_type) do
    desc "Device type"
    newvalues(:ethernet, :bridge, :bond)
    defaultto :ethernet
  end

  newproperty(:bridge_ports) do
    desc "Ports, member of bridge"
    #defaultto 'none'
    munge do |val|
      val.strip.split(/[\s,\:]+/).reject{|l| l.empty?}.join(' ')
    end
  end

  newproperty(:onboot, :parent => Puppet::Property::Boolean) do
    desc "Whether to bring the interface up on boot"
    defaultto :true
  end

  newproperty(:mtu) do
    desc "The Maximum Transmission Unit size to use for the interface"
    validate do |value|
      # reject floating point and negative integers
      # XXX this lets 1500.0 pass
      unless (value =~ /^\d+$/)
        raise ArgumentError, "#{value} is not a valid mtu (must be a positive integer)"
      end

      # Intel 82598 & 82599 chips support MTUs up to 16110; is there any
      # hardware in the wild that supports larger frames?
      #
      # It appears loopback devices routinely have large MTU values; Eg. 65536
      #
      # Frames small than 64bytes are discarded as runts.  Smallest valid MTU
      # is 42 with a 802.1q header and 46 without.
      min_mtu = 42
      max_mtu = 65536
      unless (min_mtu .. max_mtu).include?(value.to_i)
        raise ArgumentError, "#{value} is not in the valid mtu range (#{min_mtu} .. #{max_mtu})"
      end
    end
  end

  newproperty(:vlan_dev) do
    desc "802.1q vlan base device"
  end

  newproperty(:vlan_id) do
    desc "802.1q vlan ID"
    validate do |value|
      unless (value =~ /^\d+$/)
        raise ArgumentError, "#{value} is not a valid VLAN_ID (must be a positive integer)"
      end
      min_id = 2
      max_id = 4094
      unless (min_id .. max_id).include?(value.to_i)
        raise ArgumentError, "#{value} is not in the valid VLAN_ID (#{min_mtu} .. #{max_mtu})"
      end
    end
  end

  newproperty(:vlan_mode) do
    desc "802.1q vlan interface naming model"
    #newvalues(:ethernet, :bridge, :bond)
    #defaultto :ethernet
  end


  newproperty(:ipaddr) do
    desc "Primary IP address for interface"
    newvalues(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}$/, :absent, :none, :undef, :nil, :dhcp)
    aliasvalue(:absent, :none)
    aliasvalue(:absent, :undef)
    aliasvalue(:absent, :nil)
    defaultto(:absent)
  end

  newproperty(:gateway) do
    desc "Default gateway"
    newvalues(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/, :absent, :none, :undef, :nil)
    aliasvalue(:absent, :none)
    aliasvalue(:absent, :undef)
    aliasvalue(:absent, :nil)
    defaultto(:absent)
  end

  newproperty(:gateway_metric) do
    desc "Default gateway metric"
    newvalues(/^\d+$/, :absent, :none, :undef, :nil)
    aliasvalue(:absent, :none)
    aliasvalue(:absent, :undef)
    aliasvalue(:absent, :nil)
    defaultto(:absent)
    # validate do |val|
    #   if val != :absent and val.to_i < 0
    #     raise ArgumentError, "Invalid gateway metric: '#{val}'"
    #   end
    # end
  end



  # # `:options` provides an arbitrary passthrough for provider properties, so
  # # that provider specific behavior doesn't clutter up the main type but still
  # # allows for more powerful actions to be taken.
  # newproperty(:options, :required_features => :provider_options) do
  #   desc "Provider specific options to be passed to the provider"

  #   def is_to_s(hash = @is)
  #     hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
  #   end

  #   def should_to_s(hash = @should)
  #     hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
  #   end

  #   defaultto {}

  #   validate do |value|
  #     raise ArgumentError, "#{self.class} requires a hash for the options property" unless value.is_a? Hash
  #     #provider.validate
  #   end
  # end

end
# vim: set ts=2 sw=2 et :