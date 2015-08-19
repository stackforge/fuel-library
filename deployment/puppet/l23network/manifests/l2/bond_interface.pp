# This technological resource should be used for configure bond slaves only from
# l23network::l2::bond resource. No self-contained purposes given.
define l23network::l2::bond_interface (
  $bond,
  $use_ovs                 = $::l23network::use_ovs,
  $ensure                  = present,
  $mtu                     = undef,
  $interface_properties    = {},
  $provider                = undef,
) {
  include ::l23network::params
  include ::stdlib

  if $bond == 'none' {
    $master = undef
    $slave  = false
  } else {
    $master = $bond
    $slave  = true
    L2_port[$name] -> L2_bond[$bond]
    L23_stored_config[$name] -> L23_stored_config[$bond]
  }

  if ! defined(L23network::L2::Port[$name]) {
    $additional_properties = {
      use_ovs  => $use_ovs,
      mtu      => is_integer($interface_properties[mtu]) ? {false=>$mtu, default=>$interface_properties[mtu]},
      master   => $master,
      slave    => $slave,
      provider => $provider
    }

    create_resources(l23network::l2::port, {
      "${name}" => merge($interface_properties, $additional_properties)
    })
  } else {
    L23network::L2::Port<| title == $name |> {
      use_ovs  => $use_ovs,
      master   => $master,
      slave    => $slave
    }
  }
}
###