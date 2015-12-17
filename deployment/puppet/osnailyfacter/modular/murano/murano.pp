notice('MODULAR: murano.pp')

prepare_network_config(hiera('network_scheme', {}))

$murano_hash                = hiera_hash('murano_hash', {})
$murano_settings_hash       = hiera_hash('murano_settings', {})
$rabbit_hash                = hiera_hash('rabbit_hash', {})
$neutron_config             = hiera_hash('neutron_config', {})
$public_ip                  = hiera('public_vip')
$database_ip                = hiera('database_vip')
$management_ip              = hiera('management_vip')
$region                     = hiera('region', 'RegionOne')
$use_neutron                = hiera('use_neutron', false)
$service_endpoint           = hiera('service_endpoint')
$syslog_log_facility_murano = hiera('syslog_log_facility_murano')
$debug                      = pick($murano_hash['debug'], hiera('debug', false))
$verbose                    = pick($murano_hash['verbose'], hiera('verbose', true))
$default_log_levels         = hiera_hash('default_log_levels')
$use_syslog                 = hiera('use_syslog', true)
$use_stderr                 = hiera('use_stderr', false)
$rabbit_ha_queues           = hiera('rabbit_ha_queues')
$amqp_port                  = hiera('amqp_port')
$amqp_hosts                 = hiera('amqp_hosts')
$external_dns               = hiera_hash('external_dns', {})
$public_ssl_hash            = hiera_hash('public_ssl', {})
$ssl_hash                   = hiera_hash('use_ssl', {})
$primary_controller         = hiera('primary_controller')

$public_auth_protocol       = get_ssl_property($ssl_hash, $public_ssl_hash, 'keystone', 'public', 'protocol', 'http')
$public_auth_address        = get_ssl_property($ssl_hash, $public_ssl_hash, 'keystone', 'public', 'hostname', [$public_ip])

$internal_auth_protocol     = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'protocol', 'http')
$internal_auth_address      = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'hostname', [hiera('keystone_endpoint', ''), $service_endpoint, $management_vip])

$admin_auth_protocol        = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'protocol', 'http')
$admin_auth_address         = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'hostname', [hiera('keystone_endpoint', ''), $service_endpoint, $management_vip])

$api_bind_host              = get_network_role_property('murano/api', 'ipaddr')

$external_lb                = hiera('external_lb', false)

#################################################################

if $murano_hash['enabled'] {

  $firewall_rule  = '202 murano-api'

  $api_bind_port  = '8082'

  $murano_user    = pick($murano_hash['user'], 'murano')
  $tenant         = pick($murano_hash['tenant'], 'services')

  $db_type        = 'mysql'
  $db_user        = pick($murano_hash['db_user'], 'murano')
  $db_name        = pick($murano_hash['db_name'], 'murano')
  $db_password    = pick($murano_hash['db_password'])
  $db_host        = pick($murano_hash['db_host'], $database_ip)
  # LP#1526938 - python-mysqldb supports this, python-pymysql does not
  if $::os_package_type == 'debian' {
    $extra_params = { 'charset' => 'utf8', 'read_timeout' => 60 }
  } else {
    $extra_params = { 'charset' => 'utf8' }
  }
  $db_connection = os_database_connection({
    'dialect'  => $db_type,
    'host'     => $db_host,
    'database' => $db_name,
    'username' => $db_user,
    'password' => $db_password,
    'extra'    => $extra_params
  })

  $external_network = $use_neutron ? {
    true    => get_ext_net_name($neutron_config['predefined_networks']),
    default => undef,
  }

  $repository_url = has_key($murano_settings_hash, 'murano_repo_url') ? {
    true    => $murano_settings_hash['murano_repo_url'],
    default => 'http://storage.apps.openstack.org',
  }

  ####### Disable upstart startup on install #######
  tweaks::ubuntu_service_override { ['murano-api', 'murano-engine']:
    package_name => 'murano',
  }

  firewall { $firewall_rule :
    dport  => $api_bind_port,
    proto  => 'tcp',
    action => 'accept',
  }

  class { 'murano' :
    verbose             => $verbose,
    debug               => $debug,
    use_syslog          => $use_syslog,
    use_stderr          => $use_stderr,
    log_facility        => $syslog_log_facility_murano,
    database_connection => $db_connection,
    sync_db             => $primary_controller,
    auth_uri            => "${public_auth_protocol}://${public_auth_address}:5000/v2.0/",
    admin_user          => $murano_user,
    admin_password      => $murano_hash['user_password'],
    admin_tenant_name   => $tenant,
    identity_uri        => "${admin_auth_protocol}://${admin_auth_address}:35357/",
    use_neutron         => $use_neutron,
    rabbit_os_user      => $rabbit_hash['user'],
    rabbit_os_password  => $rabbit_hash['password'],
    rabbit_os_port      => $amqp_port,
    rabbit_os_host      => split($amqp_hosts, ','),
    rabbit_ha_queues    => $rabbit_ha_queues,
    rabbit_own_host     => $public_ip,
    rabbit_own_port     => $murano_hash['rabbit']['port'],
    rabbit_own_vhost    => $murano_hash['rabbit']['vhost'],
    rabbit_own_user     => $rabbit_hash['user'],
    rabbit_own_password => $rabbit_hash['password'],
    default_nameservers => pick($external_dns['dns_list'], '8.8.8.8'),
    service_host        => $api_bind_host,
    service_port        => $api_bind_port,
    external_network    => $external_network,
    use_trusts          => true,
  }

  # TODO (iberezovskiy): Move to globals (as it is done for sahara)
  # after new sync with upstream because of
  # https://github.com/openstack/puppet-murano/blob/master/manifests/init.pp#L237
  if $default_log_levels {
    murano_config {
      'DEFAULT/default_log_levels':
        value => join(sort(join_keys_to_values($default_log_levels, '=')), ',');
    }
  } else {
    murano_config {
      'DEFAULT/default_log_levels': ensure => absent;
    }
  }


  class { 'murano::api':
    host    => $api_bind_host,
    port    => $api_bind_port,
    sync_db => false,
  }

  class { 'murano::engine':
    sync_db => false,
  }

  class { 'murano::client': }

  class { 'murano::dashboard':
    repo_url => $repository_url,
  }

  $haproxy_stats_url = "http://${management_ip}:10000/;csv"

  if $external_lb {
    Haproxy_backend_status<||> {
      provider => 'http',
    }
    $murano_protocol = get_ssl_property($ssl_hash, {}, 'murano', 'internal', 'protocol', 'http')
    $murano_address  = get_ssl_property($ssl_hash, {}, 'murano', 'internal', 'hostname', [$service_endpoint, $management_vip])
    $murano_url      = "${murano_protocol}://${murano_address}:${api_bind_port}"
  }

  haproxy_backend_status { 'murano-api' :
    name => 'murano-api',
    url  => $external_lb ? {
      default => $haproxy_stats_url,
      true    => $murano_url,
    },
  }

  if roles_include('primary-controller') {

    $internal_auth_url  = "${internal_auth_protocol}://${internal_auth_address}:5000"
    $admin_identity_url = "${admin_auth_protocol}://${admin_auth_address}:35357"

    haproxy_backend_status { 'keystone-public' :
      name  => 'keystone-1',
      url   => $external_lb ? {
        default => $haproxy_stats_url,
        true    => $internal_auth_url,
      },
    }

    haproxy_backend_status { 'keystone-admin' :
      name  => 'keystone-2',
      url   => $external_lb ? {
        default => $haproxy_stats_url,
        true    => $admin_identity_url,
      },
    }

    murano::application { 'io.murano' : }

    Haproxy_backend_status['keystone-admin'] -> Haproxy_backend_status['murano-api']
    Haproxy_backend_status['keystone-public'] -> Haproxy_backend_status['murano-api']
    Haproxy_backend_status['murano-api'] -> Murano::Application['io.murano']

    Service['murano-api'] -> Murano::Application['io.murano']
  }

  Firewall[$firewall_rule] -> Class['murano::api']
  Service['murano-api'] -> Haproxy_backend_status['murano-api']
}
#########################

class openstack::firewall {}
include openstack::firewall
