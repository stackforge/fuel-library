notice('MODULAR: keystone/workloads_collector_add.pp')

$workloads_hash   = hiera('workloads_collector', {})
$service_endpoint = hiera('service_endpoint')
$external_lb      = hiera('external_lb', false)
$ssl_hash         = hiera_hash('use_ssl', {})
$management_vip   = hiera('management_vip')

$haproxy_stats_url = "http://${service_endpoint}:10000/;csv"

class {'::osnailyfacter::wait_for_keystone_backends':}

Class[::Osnailyfacter::Wait_for_keystone_backends] -> Class['::openstack::workloads_collector']

class { 'openstack::workloads_collector':
  enabled               => $workloads_hash['enabled'],
  workloads_username    => $workloads_hash['username'],
  workloads_password    => $workloads_hash['password'],
  workloads_tenant      => $workloads_hash['tenant'],
  workloads_create_user => true,
}
