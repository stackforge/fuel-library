class osnailyfacter::openstack_haproxy::openstack_haproxy_mysqld {

  notice('MODULAR: openstack_haproxy/openstack_haproxy_mysqld.pp')
  $override_configuration = hiera_hash(configuration, {})
  $override_configuration_options = hiera_hash(configuration_options, {})

  $mysql_hash               = hiera_hash('mysql', {})
  # enabled by default
  $use_mysql                = pick($mysql_hash['enabled'], true)

  $custom_mysql_setup_class = hiera('custom_mysql_setup_class', 'galera')

  $external_lb              = hiera('external_lb', false)

  override_resources {'override-resources':
    configuration => $override_configuration,
    options       => $override_configuration_options,
  }

  # only do this if mysql is enabled and we are using one of the galera/percona classes
  if !$external_lb and $use_mysql and ($custom_mysql_setup_class in ['galera', 'percona', 'percona_packages']) {
    $database_address_map = get_node_to_ipaddr_map_by_network_role(hiera_hash('database_nodes'), 'mgmt/database')
    $server_names         = hiera_array('mysqld_names', keys($database_address_map))
    $ipaddresses          = hiera_array('mysqld_ipaddresses', values($database_address_map))
    $public_virtual_ip    = hiera('public_vip')
    $internal_virtual_ip  = pick(hiera('database_vip', undef), hiera('management_vip'))

    $primary_controller   = hiera('primary_controller')

    # configure mysql ha proxy
    class { '::openstack::ha::mysqld':
      internal_virtual_ip   => $internal_virtual_ip,
      ipaddresses           => $ipaddresses,
      public_virtual_ip     => $public_virtual_ip,
      server_names          => $server_names,
      is_primary_controller => $primary_controller,
    }
  }

}
