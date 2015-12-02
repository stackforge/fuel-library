notice('MODULAR: murano/cfapi-keystone.pp')

$murano_cfapi_hash = hiera_hash('murano-cfapi', {})
$public_ip         = hiera('public_vip')
$management_ip     = hiera('management_vip')
$region            = hiera('region', 'RegionOne')
$public_ssl_hash   = hiera('public_ssl')
$ssl_hash          = hiera_hash('use_ssl', {})

$public_protocol   = get_ssl_property($ssl_hash, $public_ssl_hash, 'murano', 'public', 'protocol', 'http')
$public_address    = get_ssl_property($ssl_hash, $public_ssl_hash, 'murano', 'public', 'hostname', [$public_ip])

$internal_protocol = get_ssl_property($ssl_hash, {}, 'murano', 'internal', 'protocol', 'http')
$internal_address  = get_ssl_property($ssl_hash, {}, 'murano', 'internal', 'hostname', [$management_ip])

$admin_protocol    = get_ssl_property($ssl_hash, {}, 'murano', 'admin', 'protocol', 'http')
$admin_address     = get_ssl_property($ssl_hash, {}, 'murano', 'admin', 'hostname', [$management_ip])

$api_bind_port     = '8083'
$tenant            = pick($murano_cfapi_hash['tenant'], 'services')
$public_url        = "${public_protocol}://${public_address}:${api_bind_port}"
$internal_url      = "${internal_protocol}://${internal_address}:${api_bind_port}"
$admin_url         = "${admin_protocol}://${admin_address}:${api_bind_port}"

#################################################################

class { 'murano::keystone::auth':
  password            => $murano_cfapi_hash['user_password'],
  service_type        => 'service_broker',
  service_description => 'Murano CloudFoundry Service Broker',
  region              => $region,
  tenant              => $tenant,
  public_url          => $public_url,
  internal_url        => $internal_url,
  admin_url           => $admin_url,
  service_name        => 'murano-cfapi',
}
