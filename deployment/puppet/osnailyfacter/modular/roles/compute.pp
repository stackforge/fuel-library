import '../common/globals.pp'

if $use_neutron {
  $private_interface = false
  $network_config_real = false
} else {
  $private_interface = hiera('fixed_interface')
  $network_config_real = $network_config
}

$glance_api_servers = "${controller_node_address}:9292"

class { 'openstack::compute':
  public_interface               => $public_int,
  private_interface              => $private_interface,
  internal_address               => $internal_address,
  libvirt_type                   => hiera('libvirt_type'),
  fixed_range                    => hiera('fixed_network_range'),
  network_manager                => $network_manager,
  network_config                 => $network_config_real,
  multi_host                     => $multi_host,
  sql_connection                 => $sql_connection,
  nova_user_password             => $nova_hash['user_password'],
  ceilometer                     => $ceilometer_hash['enabled'],
  ceilometer_metering_secret     => $ceilometer_hash['metering_secret'],
  ceilometer_user_password       => $ceilometer_hash['user_password'],
  queue_provider                 => $queue_provider,
  amqp_hosts                     => $amqp_hosts,
  amqp_user                      => $rabbit_hash['user'],
  amqp_password                  => $rabbit_hash['password'],
  auto_assign_floating_ip        => hiera('auto_assign_floating_ip'),
  glance_api_servers             => $glance_api_servers,
  vncproxy_host                  => $controller_node_public,
  vncserver_listen               => '0.0.0.0',
  vnc_enabled                    => true,
  network_provider               => $network_provider,
  neutron_user_password          => $neutron_user_password,
  base_mac                       => $base_mac,
  service_endpoint               => $controller_node_address,
  cinder                         => true,
  cinder_user_password           => $cinder_hash['user_password'],
  cinder_db_password             => $cinder_hash['db_password'],
  cinder_iscsi_bind_addr         => $cinder_iscsi_bind_addr,
  cinder_volume_group            => 'cinder',
  manage_volumes                 => $manage_volumes,
  db_host                        => $controller_node_address,
  debug                          => $debug,
  verbose                        => $verbose,
  use_syslog                     => $use_syslog,
  syslog_log_facility            => $syslog_log_facility_nova,
  syslog_log_facility_neutron    => $syslog_log_facility_neutron,
  syslog_log_facility_ceilometer => $syslog_log_facility_ceilometer,
  state_path                     => $nova_hash['state_path'],
  nova_rate_limits               => $nova_rate_limits,
  nova_report_interval           => $nova_report_interval,
  nova_service_down_time         => $nova_service_down_time,
  cinder_rate_limits             => $cinder_rate_limits,
}

nova_config { 'DEFAULT/start_guests_on_host_boot' : value => hiera('start_guests_on_host_boot') }
nova_config { 'DEFAULT/use_cow_images'            : value => hiera('use_cow_images') }
nova_config { 'DEFAULT/compute_scheduler_driver'  : value => hiera('compute_scheduler_driver') }
