# type for managing persistent interface config options
# Inspired by puppet-network module. Adrien, thanks.

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
    newvalues(:static, :absent, :manual, :dhcp, :loopback, :none, :undef, :nil)
    aliasvalue(:none,  :manual)
    aliasvalue(:undef, :absent)
    aliasvalue(:nil,   :absent)
    defaultto :manual
  end

  # newproperty(:port_type) do
  #   desc "port_type fake RO property"
  # end

  newproperty(:if_type) do
    desc "Device type. Service property, shouldn't be setting by puppet"
    newvalues(:ethernet, :bridge, :bond)
  end

  newproperty(:bridge, :array_matching => :all) do
    # Array_matching for this property required for very complicated cases
    # ex. patchcord for connectind two bridges or bridge and network namesspace
    desc "Name of bridge, including this port"
    newvalues(/^[\w+\-]+$/, :none, :undef, :nil, :absent)
    aliasvalue(:none,  :absent)
    aliasvalue(:undef, :absent)
    aliasvalue(:nil,   :absent)
    defaultto :absent
  end

  newproperty(:jacks, :array_matching => :all) do
    desc "Name of jacks for patchcord"
    newvalues(/^[\w+\-]+$/)
  end

  newproperty(:bridge_ports, :array_matching => :all) do
    desc "Ports, member of bridge, service property, do not use directly."
  end

  newproperty(:bridge_stp) do
    desc "Whether stp enable"
    newvalues(:true, :absent, :yes, :on, :false, :no, :off)
    aliasvalue(:yes, :true)
    aliasvalue(:on,  :true)
    aliasvalue(:no,  :false)
    aliasvalue(:off, :false)
    defaultto :absent
  end

  newproperty(:onboot) do
    desc "Whether to bring the interface up on boot"
    newvalues(:true, :yes, :on, :false, :no, :off)
    aliasvalue(:yes, :true)
    aliasvalue(:on,  :true)
    aliasvalue(:no,  :false)
    aliasvalue(:off, :false)
    defaultto :true
  end

  newproperty(:mtu) do
    desc "The Maximum Transmission Unit size to use for the interface"
    newvalues(/^\d+$/, :absent, :none, :undef, :nil)
    aliasvalue(:none,  :absent)
    aliasvalue(:undef, :absent)
    aliasvalue(:nil,   :absent)
    aliasvalue(0,      :absent)
    defaultto :absent   # MTU value should be undefined by default, because some network resources (bridges, subinterfaces)
    validate do |value| #     inherits it from a parent interface
      # Intel 82598 & 82599 chips support MTUs up to 16110; is there any
      # hardware in the wild that supports larger frames?
      #
      # It appears loopback devices routinely have large MTU values; Eg. 65536
      #
      # Frames small than 64bytes are discarded as runts.  Smallest valid MTU
      # is 42 with a 802.1q header and 46 without.
      min_mtu = 42
      max_mtu = 65536
      if ! (value.to_s == 'absent' or (min_mtu .. max_mtu).include?(value.to_i))
        raise ArgumentError, "'#{value}' is not a valid mtu (must be a positive integer in range (#{min_mtu} .. #{max_mtu})"
      end
    end
    munge do |val|
      ((val == :absent)  ?  :absent  :  val.to_i)
    end
  end

  newproperty(:vlan_dev) do
    desc "802.1q vlan base device"
  end

  newproperty(:vlan_id) do
    desc "802.1q vlan ID"
    newvalues(/^\d+$/, :absent, :none, :undef, :nil)
    aliasvalue(:none,  :absent)
    aliasvalue(:undef, :absent)
    aliasvalue(:nil,   :absent)
    aliasvalue(0,      :absent)
    defaultto :absent
    validate do |val|
      min_vid = 1
      max_vid = 4094
      if ! (val.to_s == 'absent' or (min_vid .. max_vid).include?(val.to_i))
        raise ArgumentError, "'#{val}' is not a valid 802.1q NALN_ID (must be a integer value in range (#{min_vid} .. #{max_vid})"
      end
    end
    munge do |val|
      ((val == :absent)  ?  :absent  :  val.to_i)
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
    aliasvalue(:none,  :absent)
    aliasvalue(:undef, :absent)
    aliasvalue(:nil,   :absent)
    defaultto :absent
  end

  newproperty(:gateway) do
    desc "Default gateway"
    newvalues(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/, :absent, :none, :undef, :nil)
    aliasvalue(:none,  :absent)
    aliasvalue(:undef, :absent)
    aliasvalue(:nil,   :absent)
    defaultto :absent
  end

  newproperty(:gateway_metric) do
    desc "Default gateway metric"
    newvalues(/^\d+$/, :absent, :none, :undef, :nil)
    aliasvalue(:none,  :absent)
    aliasvalue(:undef, :absent)
    aliasvalue(:nil,   :absent)
    aliasvalue(0,      :absent)
    defaultto :absent
    validate do |val|
      min_metric = 0
      max_metric = 65535
      if ! (val.to_s == 'absent' or (min_metric .. max_metric).include?(val.to_i))
        raise ArgumentError, "'#{val}' is not a valid metric (must be a integer value in range (#{min_metric} .. #{max_metric})"
      end
    end
    munge do |val|
      ((val == :absent)  ?  :absent  :  val.to_i)
    end
  end

  newproperty(:bond_master) do
    desc "bond name for bonded interface"
    newvalues(/^[\w+\-]+$/, :none, :undef, :nil, :absent)
    aliasvalue(:none,  :absent)
    aliasvalue(:undef, :absent)
    aliasvalue(:nil,   :absent)
    defaultto :absent
  end

  newproperty(:bond_slaves, :array_matching => :all) do
    desc "slave ports for bond interface"
    newvalues(/^[\w+\-]+$/, :false, :none, :undef, :nil, :absent)
    #aliasvalue(:absent, :none)  # none is a valid config value
    aliasvalue(:false, :none)
    aliasvalue(:undef, :absent)
    aliasvalue(:nil,   :absent)
    defaultto :absent
  end

  newproperty(:bond_mode)
  newproperty(:bond_miimon)
  newproperty(:bond_lacp_rate)

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

  def generate
    return if ! (!([:absent, :none, :nil, :undef] & self[:bridge]).any? \
                and [:ethernet, :bond].include? self[:if_type]
                )
    self[:bridge].each do |bridge|
      br = self.catalog.resource('L23_stored_config', bridge)
      fail("Stored_config resource for bridge '#{bridge}' not found for port '#{self[:name]}'!") if ! br
      br[:bridge_ports] ||= []
      ports = br[:bridge_ports]
      return if ! ports.is_a? Array
      if ! ports.include? self[:name]
        ports << self[:name].to_s
        br[:bridge_ports] = ports.reject{|a| a=='none'}.sort
      end
    end
    nil
  end

end
# vim: set ts=2 sw=2 et :