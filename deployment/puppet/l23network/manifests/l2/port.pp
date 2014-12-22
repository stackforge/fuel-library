# == Define: l23network::l2::port
#
# Create open vSwitch port and add to the OVS bridge.
#
# === Parameters
#
# [*name*]
#   Port name.
#
# [*bridge*]
#   Bridge that will contain this port.
#
# [*type*]
#   Port type can be set to one of the following values:
#   'system', 'internal', 'tap', 'gre', 'ipsec_gre', 'capwap', 'patch', 'null'.
#   If you do not define of leave this value empty then ovs-vsctl will create
#   the port with default behavior.
#   (see http://openvswitch.org/cgi-bin/ovsman.cgi?page=utilities%2Fovs-vsctl.8)
#
# [*vlan_id*]
#   Specify 802.1q tag for result bond. If need.
#
# [*trunks*]
#   Specify array of 802.1q tags if need configure bond in trunk mode.
#   Define trunks => [0] if you need pass only untagged traffic.
#
# [*skip_existing*]
#   If this port already exists it will be ignored without any errors.
#   Must be true or false.
#
define l23network::l2::port (
  $ensure                = present,
  $port                  = $name,
  $bridge                = undef,
  $vlan_id               = undef, # actually only for OVS workflow
  $vlan_dev              = undef,
  $mtu                   = undef,
  $onboot                = undef,
# $type                  = undef, # was '',
# $trunks                = [],
  $skip_existing         = undef,
  $provider              = undef,
) {
  # Detect VLAN mode configuration
  case $port {
    /^vlan(\d+)/: {
      $port_name = $port
      $port_vlan_mode = 'vlan'
      if $vlan_id {
        $port_vlan_id = $vlan_id
      } else {
        $port_vlan_id = $1
      }
      if $vlan_dev {
        $port_vlan_dev = $vlan_dev
      } else {
        fail("Can't configure vlan interface ${port} without definition vlandev=>ethXX.")
      }
    }
    /^(eth\d+)\.(\d+)/: {
      $port_vlan_mode = 'eth'
      $port_vlan_id   = $2
      $port_vlan_dev  = $1
      $port_name      = "${1}.${2}"
    }
    default: {
      $port_vlan_mode = undef
      $port_vlan_id   = undef
      $port_vlan_dev  = undef
      $port_name      = $port
    }
  }

  if ! defined (L2_port[$port_name]) {
    if $provider {
      $config_provider = "${provider}_${::l23_os}"
    } else {
      $config_provider = undef
    }

    if ! defined (L23_stored_config[$port_name]) {
      l23_stored_config { $port_name: }
    }
    L23_stored_config[$port_name] {
      ensure        => $ensure,
      if_type       => 'ethernet',
      vlan_id       => $port_vlan_id,
      vlan_dev      => $port_vlan_dev,
      vlan_mode     => $port_vlan_mode,
      mtu           => $mtu,
      onboot        => $onboot,
      provider      => $config_provider
    }

    l2_port { $port_name :
      ensure               => $ensure,
      bridge               => $bridge,
      vlan_id              => $port_vlan_id,
      vlan_dev             => $port_vlan_dev,
      vlan_mode            => $port_vlan_mode,
      mtu                  => $mtu,
      onboot               => $onboot,
      #type                 => $type,
      #trunks               => $trunks,
      #vlan_splinters       => $vlan_splinters,
      #port_properties      => $port_properties,
      #interface_properties => $interface_properties,
      provider             => $provider
    }
  }
}
