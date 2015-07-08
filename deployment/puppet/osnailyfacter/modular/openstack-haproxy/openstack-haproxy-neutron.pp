notice('MODULAR: openstack-haproxy-neutron.pp')

# NOT enabled by default
$use_neutron         = hiera('use_neutron', false)
$public_ssl_hash     = hiera('public_ssl')

$controllers              = hiera('controllers')
$controllers_server_names = filter_hash($controllers, 'name')
$controllers_ipaddresses  = filter_hash($controllers, 'internal_address')

if ($use_neutron) {
  $server_names        = pick(hiera_array('neutron_names', undef),
                              $controllers_server_names)
  $ipaddresses         = pick(hiera_array('neutron_ipaddresses', undef),
                              $controllers_ipaddresses)
  $public_virtual_ip   = hiera('public_vip')
  $internal_virtual_ip = hiera('management_vip')

  # configure neutron ha proxy
  class { '::openstack::ha::neutron':
    internal_virtual_ip => $internal_virtual_ip,
    ipaddresses         => $ipaddresses,
    public_virtual_ip   => $public_virtual_ip,
    server_names        => $server_names,
    public_ssl          => $public_ssl_hash['services'],
  }
}
