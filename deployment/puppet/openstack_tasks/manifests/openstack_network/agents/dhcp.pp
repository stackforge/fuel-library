class openstack_tasks::openstack_network::agents::dhcp {

  notice('MODULAR: openstack_network/agents/dhcp.pp')

  $use_neutron = hiera('use_neutron', false)

  if $use_neutron {

    $debug                   = hiera('debug', true)
    $resync_interval         = '30'
    $isolated_metadata       = try_get_value($neutron_config, 'metadata/isolated_metadata', true)

    $neutron_advanced_config = hiera_hash('neutron_advanced_configuration', { })
    $ha_agent                = try_get_value($neutron_advanced_config, 'dhcp_agent_ha', true)

    class { '::neutron::agents::dhcp':
      debug                    => $debug,
      resync_interval          => $resync_interval,
      manage_service           => true,
      enable_isolated_metadata => $isolated_metadata,
      enabled                  => true,
    }

    if $ha_agent {
      $primary_neutron = has_primary_role(intersection(hiera('neutron_roles'), hiera('roles')))
      class { '::cluster::neutron::dhcp' :
        primary => $primary_neutron,
      }
    }

    # stub package for 'neutron::agents::dhcp' class
    package { 'neutron':
      name   => 'binutils',
      ensure => 'installed',
    }

  }

  if is_file_updated('/etc/neutron/neutron.conf', $title) {
      notify{'neutron.conf has been changed, going to restart dhcp agent':
    } ~> Service['neutron-dhcp-service']
  }
}
