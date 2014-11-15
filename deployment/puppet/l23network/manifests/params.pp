class l23network::params {
  case $::osfamily {
    /(?i)debian/: {
      $ovs_service_name   = 'openvswitch-switch'
      $ovs_status_cmd     = '/etc/init.d/openvswitch-switch status'
      $lnx_vlan_tools     = 'vlan'
      $lnx_bond_tools     = 'ifenslave'
      $lnx_ethernet_tools = 'ethtool'
      $ovs_datapath_package_name = $::kernelmajversion < 3.13 ? {
        true    => 'openvswitch-datapath-lts-saucy-dkms',
        default => undef
      }
      $ovs_common_package_name = 'openvswitch-switch'
    }
    /(?i)redhat/: {
      $ovs_service_name   = 'openvswitch' #'ovs-vswitchd'
      $ovs_status_cmd     = '/etc/init.d/openvswitch status'
      $lnx_vlan_tools     = 'vconfig'
      $lnx_bond_tools     = undef
      $lnx_ethernet_tools = 'ethtool'
      $ovs_datapath_package_name = 'kmod-openvswitch'
      $ovs_common_package_name   = 'openvswitch'
    }
    default: {
      fail("Unsupported OS: ${::osfamily}/${::operatingsystem}")
    }
  }
}
