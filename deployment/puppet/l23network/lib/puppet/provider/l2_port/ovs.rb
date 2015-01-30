require File.join(File.dirname(__FILE__), '..','..','..','puppet/provider/ovs_base')

Puppet::Type.type(:l2_port).provide(:ovs, :parent => Puppet::Provider::Ovs_base) do
#  confine    :osfamily => :linux
  commands   :vsctl   => 'ovs-vsctl',
             :iproute => 'ip'


  def self.add_unremovable_flag(port_props)
    # calculate 'unremovable' flag. Should be re-defined in chield providers
    if port_props[:port_type].include? 'bridge' or port_props[:port_type].include? 'bond'
      port_props[:port_type] << 'unremovable'
    end
  end

  def self.get_instances(big_hash)
    big_hash[:port]
  end

  #-----------------------------------------------------------------

  def create
    debug("CREATE resource: #{@resource}")
    @old_property_hash = {}
    @property_flush = {}.merge! @resource
    #
    cmd = ["add-port", @resource[:bridge], @resource[:interface]]
    # # tag and trunks for port
    # port_properties = @resource[:port_properties]
    # if ![nil, :absent].include? @resource[:vlan_id] and @resource[:vlan_id] > 0
    #   port_properties << "tag=#{@resource[:vlan_id]}"
    # end
    # if ![nil, :absent].include? @resource[:trunks] and !@resource[:trunks].empty?
    #   port_properties.insert(-1, "trunks=[#{@resource[:trunks].join(',')}]")
    # end
    # Port create begins from definition brodge and port
    # # add port properties (k/w) to command line
    # if not port_properties.empty?
    #   for option in port_properties
    #     cmd.insert(-1, option)
    #   end
    # end
    # set interface type
    if @resource[:type] and (@resource[:type].to_s != '' or @resource[:type].to_s != :absent)
      tt = "type=" + @resource[:type].to_s
    else
      tt = "type=internal"
    end
    cmd += ['--', "set", "Interface", @resource[:interface], tt]
    # executing OVS add-port command
    begin
      vsctl(cmd)
    rescue Puppet::ExecutionFailure => error
      raise Puppet::ExecutionFailure, "Can't add port '#{@resource[:interface]}'\n#{error}"
    end
    # # set interface properties
    # if @resource[:interface_properties]
    #   for option in @resource[:interface_properties]
    #     begin
    #       vsctl('--', "set", "Interface", @resource[:interface], option.to_s)
    #     rescue Puppet::ExecutionFailure => error
    #       raise Puppet::ExecutionFailure, "Interface '#{@resource[:interface]}' can't set option '#{option}':\n#{error}"
    #     end
    #   end
    # end
  end

  def destroy
    vsctl("del-port", @resource[:bridge], @resource[:interface])
  end

  def flush
    if @property_flush
      debug("FLUSH properties: #{@property_flush}")
      if @property_flush.has_key? :mtu
        if !@property_flush[:mtu].nil? and @property_flush[:mtu] != :absent
          #todo(sv): process array if interfaces
          iproute('link', 'set', 'mtu', @property_flush[:mtu].to_i, 'dev', @resource[:interface])
        else
          # remove MTU
          #todo(sv): process array if interfaces
          iproute('link', 'set', 'mtu', '1500', 'dev', @resource[:interface])
        end
      end
      if @property_flush.has_key? :vlan_id
        if !@property_flush[:vlan_id].nil? and @property_flush[:vlan_id] != :absent
          vsctl('set', 'Port', @resource[:interface], "tag=#{@property_flush[:vlan_id].to_i}")
        else
          # remove 802.1q tag
          vsctl('set', 'Port', @resource[:interface], "tag='[]'")
        end
      end
      @property_hash = resource.to_hash
    end
  end

  #-----------------------------------------------------------------

end
# vim: set ts=2 sw=2 et :