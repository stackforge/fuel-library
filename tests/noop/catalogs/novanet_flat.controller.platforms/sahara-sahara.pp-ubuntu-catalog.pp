class { 'Mysql::Bindings::Python':
  name => 'Mysql::Bindings::Python',
}

class { 'Mysql::Bindings':
  name => 'Mysql::Bindings',
}

class { 'Mysql::Params':
  name => 'Mysql::Params',
}

class { 'Mysql::Python':
  name           => 'Mysql::Python',
  package_ensure => 'present',
  package_name   => 'python-mysqldb',
}

class { 'Openstack::Firewall':
  name => 'Openstack::Firewall',
}

class { 'Sahara::Client':
  name           => 'Sahara::Client',
  package_ensure => 'present',
}

class { 'Sahara::Db::Sync':
  name => 'Sahara::Db::Sync',
}

class { 'Sahara::Db':
  database_connection     => 'mysql://sahara:secrete@localhost:3306/sahara',
  database_idle_timeout   => '3600',
  database_max_overflow   => '20',
  database_max_pool_size  => '10',
  database_max_retries    => '10',
  database_min_pool_size  => '1',
  database_retry_interval => '10',
  name                    => 'Sahara::Db',
  require                 => ['Class[Mysql::Bindings]', 'Class[Mysql::Bindings::Python]'],
}

class { 'Sahara::Logging':
  debug        => 'false',
  log_dir      => '/var/log/sahara',
  log_facility => 'LOG_USER',
  name         => 'Sahara::Logging',
  use_stderr   => 'true',
  use_syslog   => 'false',
  verbose      => 'false',
}

class { 'Sahara::Notify':
  control_exchange     => 'openstack',
  enable_notifications => 'true',
  name                 => 'Sahara::Notify',
  notification_driver  => 'messaging',
  notification_level   => 'INFO',
  notification_topics  => 'notifications',
}

class { 'Sahara::Params':
  name => 'Sahara::Params',
}

class { 'Sahara::Policy':
  name        => 'Sahara::Policy',
  notify      => ['Service[sahara-api]', 'Service[sahara-engine]'],
  policies    => {},
  policy_path => '/etc/sahara/policy.json',
}

class { 'Sahara::Service::Api':
  api_workers    => '0',
  enabled        => 'true',
  manage_service => 'true',
  name           => 'Sahara::Service::Api',
  package_ensure => 'present',
  require        => 'Class[Sahara]',
}

class { 'Sahara::Service::Engine':
  enabled        => 'true',
  manage_service => 'true',
  name           => 'Sahara::Service::Engine',
  package_ensure => 'present',
  require        => 'Class[Sahara]',
}

class { 'Sahara':
  admin_password         => 'xqnj91LB',
  admin_tenant_name      => 'services',
  admin_user             => 'sahara',
  amqp_durable_queues    => 'false',
  auth_uri               => 'http://10.108.2.2:5000/v2.0/',
  cast_timeout           => '30',
  database_connection    => 'mysql://sahara:LwV220yW@10.108.2.2/sahara?read_timeout=60',
  database_idle_timeout  => '3600',
  database_max_overflow  => '20',
  database_max_pool_size => '20',
  database_max_retries   => '-1',
  debug                  => 'true',
  host                   => '10.108.2.4',
  identity_uri           => 'http://10.108.2.2:35357/',
  kombu_reconnect_delay  => '1.0',
  kombu_ssl_version      => 'TLSv1',
  log_facility           => 'LOG_LOCAL0',
  name                   => 'Sahara',
  package_ensure         => 'present',
  plugins                => ['ambari', 'cdh', 'mapr', 'spark', 'vanilla'],
  port                   => '8386',
  qpid_heartbeat         => '60',
  qpid_hostname          => 'localhost',
  qpid_hosts             => 'false',
  qpid_password          => 'guest',
  qpid_port              => '5672',
  qpid_protocol          => 'tcp',
  qpid_receiver_capacity => '1',
  qpid_sasl_mechanisms   => '',
  qpid_tcp_nodelay       => 'true',
  qpid_topology_version  => '2',
  qpid_username          => 'guest',
  rabbit_ha_queues       => 'true',
  rabbit_host            => 'localhost',
  rabbit_hosts           => ['10.108.2.4:5673', ' 10.108.2.6:5673', ' 10.108.2.5:5673'],
  rabbit_login_method    => 'AMQPLAIN',
  rabbit_max_retries     => '0',
  rabbit_password        => 'U7sRLche',
  rabbit_port            => '5673',
  rabbit_retry_backoff   => '2',
  rabbit_retry_interval  => '1',
  rabbit_use_ssl         => 'false',
  rabbit_userid          => 'nova',
  rabbit_virtual_host    => '/',
  rpc_backend            => 'rabbit',
  sync_db                => 'true',
  use_floating_ips       => 'true',
  use_neutron            => 'false',
  use_ssl                => 'false',
  use_stderr             => 'false',
  use_syslog             => 'true',
  verbose                => 'true',
  zeromq_bind_address    => '*',
  zeromq_contexts        => '1',
  zeromq_host            => 'sahara',
  zeromq_ipc_dir         => '/var/run/openstack',
  zeromq_port            => '9501',
  zeromq_topic_backlog   => 'None',
}

class { 'Settings':
  name => 'Settings',
}

class { 'main':
  name => 'main',
}

exec { 'remove_sahara-api_override':
  before  => ['Service[sahara-api]', 'Service[sahara-api]'],
  command => 'rm -f /etc/init/sahara-api.override',
  onlyif  => 'test -f /etc/init/sahara-api.override',
  path    => ['/sbin', '/bin', '/usr/bin', '/usr/sbin'],
}

exec { 'sahara-dbmanage':
  command     => 'sahara-db-manage --config-file /etc/sahara/sahara.conf upgrade head',
  logoutput   => 'on_failure',
  notify      => ['Service[sahara-api]', 'Service[sahara-engine]'],
  path        => '/usr/bin',
  refreshonly => 'true',
  user        => 'sahara',
}

file { '/etc/pki/tls/certs/public_haproxy.pem':
  mode => '644',
  path => '/etc/pki/tls/certs/public_haproxy.pem',
}

file { '/etc/pki/tls/certs':
  mode => '755',
  path => '/etc/pki/tls/certs',
}

file { 'create_sahara-api_override':
  ensure  => 'present',
  before  => 'Exec[remove_sahara-api_override]',
  content => 'manual',
  group   => 'root',
  mode    => '0644',
  owner   => 'root',
  path    => '/etc/init/sahara-api.override',
}

firewall { '201 sahara-api':
  action => 'accept',
  before => 'Class[Sahara::Service::Api]',
  dport  => '8386',
  name   => '201 sahara-api',
  proto  => 'tcp',
}

haproxy_backend_status { 'sahara':
  name => 'sahara',
  url  => 'http://10.108.2.2:10000/;csv',
}

package { 'python-mysqldb':
  ensure => 'present',
  name   => 'python-mysqldb',
}

package { 'python-saharaclient':
  ensure => 'present',
  name   => 'python-saharaclient',
  tag    => 'openstack',
}

package { 'sahara-api':
  ensure => 'present',
  name   => 'sahara-api',
  notify => ['Service[sahara-api]', 'Exec[sahara-dbmanage]'],
  tag    => ['openstack', 'sahara-package'],
}

package { 'sahara-common':
  ensure => 'present',
  before => 'Class[Sahara::Policy]',
  name   => 'sahara-common',
  notify => 'Exec[sahara-dbmanage]',
  tag    => ['openstack', 'sahara-package'],
}

package { 'sahara-engine':
  ensure => 'present',
  name   => 'sahara-engine',
  notify => ['Service[sahara-engine]', 'Exec[sahara-dbmanage]'],
  tag    => ['openstack', 'sahara-package'],
}

sahara_config { 'DEFAULT/api_workers':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/api_workers',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '0',
}

sahara_config { 'DEFAULT/control_exchange':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/control_exchange',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'openstack',
}

sahara_config { 'DEFAULT/debug':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/debug',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'true',
}

sahara_config { 'DEFAULT/default_log_levels':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/default_log_levels',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'DEFAULT/enable_notifications':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/enable_notifications',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'true',
}

sahara_config { 'DEFAULT/fatal_deprecations':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/fatal_deprecations',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'DEFAULT/host':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/host',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '10.108.2.4',
}

sahara_config { 'DEFAULT/instance_format':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/instance_format',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'DEFAULT/instance_uuid_format':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/instance_uuid_format',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'DEFAULT/log_config_append':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/log_config_append',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'DEFAULT/log_date_format':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/log_date_format',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'DEFAULT/log_dir':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/log_dir',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '/var/log/sahara',
}

sahara_config { 'DEFAULT/logging_context_format_string':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/logging_context_format_string',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'DEFAULT/logging_debug_format_suffix':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/logging_debug_format_suffix',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'DEFAULT/logging_default_format_string':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/logging_default_format_string',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'DEFAULT/logging_exception_prefix':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/logging_exception_prefix',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'DEFAULT/notification_driver':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/notification_driver',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'messaging',
}

sahara_config { 'DEFAULT/notification_level':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/notification_level',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'INFO',
}

sahara_config { 'DEFAULT/notification_topics':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/notification_topics',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'notifications',
}

sahara_config { 'DEFAULT/plugins':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/plugins',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'ambari,cdh,mapr,spark,vanilla',
}

sahara_config { 'DEFAULT/port':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/port',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '8386',
}

sahara_config { 'DEFAULT/publish_errors':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/publish_errors',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'DEFAULT/rpc_backend':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/rpc_backend',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'rabbit',
}

sahara_config { 'DEFAULT/syslog_log_facility':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/syslog_log_facility',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'LOG_LOCAL0',
}

sahara_config { 'DEFAULT/use_floating_ips':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/use_floating_ips',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'true',
}

sahara_config { 'DEFAULT/use_neutron':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/use_neutron',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'false',
}

sahara_config { 'DEFAULT/use_stderr':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/use_stderr',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'false',
}

sahara_config { 'DEFAULT/use_syslog':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/use_syslog',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'true',
}

sahara_config { 'DEFAULT/verbose':
  before => 'Exec[sahara-dbmanage]',
  name   => 'DEFAULT/verbose',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'true',
}

sahara_config { 'database/connection':
  before => 'Exec[sahara-dbmanage]',
  name   => 'database/connection',
  notify => ['Exec[sahara-dbmanage]', 'Service[sahara-api]', 'Service[sahara-engine]'],
  secret => 'true',
  value  => 'mysql://sahara:LwV220yW@10.108.2.2/sahara?read_timeout=60',
}

sahara_config { 'database/idle_timeout':
  before => 'Exec[sahara-dbmanage]',
  name   => 'database/idle_timeout',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '3600',
}

sahara_config { 'database/max_overflow':
  before => 'Exec[sahara-dbmanage]',
  name   => 'database/max_overflow',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '20',
}

sahara_config { 'database/max_pool_size':
  before => 'Exec[sahara-dbmanage]',
  name   => 'database/max_pool_size',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '20',
}

sahara_config { 'database/max_retries':
  before => 'Exec[sahara-dbmanage]',
  name   => 'database/max_retries',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '-1',
}

sahara_config { 'database/min_pool_size':
  before => 'Exec[sahara-dbmanage]',
  name   => 'database/min_pool_size',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '1',
}

sahara_config { 'database/retry_interval':
  before => 'Exec[sahara-dbmanage]',
  name   => 'database/retry_interval',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '10',
}

sahara_config { 'keystone_authtoken/admin_password':
  before => 'Exec[sahara-dbmanage]',
  name   => 'keystone_authtoken/admin_password',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  secret => 'true',
  value  => 'xqnj91LB',
}

sahara_config { 'keystone_authtoken/admin_tenant_name':
  before => 'Exec[sahara-dbmanage]',
  name   => 'keystone_authtoken/admin_tenant_name',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'services',
}

sahara_config { 'keystone_authtoken/admin_user':
  before => 'Exec[sahara-dbmanage]',
  name   => 'keystone_authtoken/admin_user',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'sahara',
}

sahara_config { 'keystone_authtoken/auth_uri':
  before => 'Exec[sahara-dbmanage]',
  name   => 'keystone_authtoken/auth_uri',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'http://10.108.2.2:5000/v2.0/',
}

sahara_config { 'keystone_authtoken/identity_uri':
  before => 'Exec[sahara-dbmanage]',
  name   => 'keystone_authtoken/identity_uri',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'http://10.108.2.2:35357/',
}

sahara_config { 'object_store_access/public_identity_ca_file':
  before => 'Exec[sahara-dbmanage]',
  name   => 'object_store_access/public_identity_ca_file',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '/etc/pki/tls/certs/public_haproxy.pem',
}

sahara_config { 'object_store_access/public_object_store_ca_file':
  before => 'Exec[sahara-dbmanage]',
  name   => 'object_store_access/public_object_store_ca_file',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '/etc/pki/tls/certs/public_haproxy.pem',
}

sahara_config { 'oslo_messaging_rabbit/amqp_durable_queues':
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/amqp_durable_queues',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'false',
}

sahara_config { 'oslo_messaging_rabbit/kombu_reconnect_delay':
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/kombu_reconnect_delay',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '1.0',
}

sahara_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/kombu_ssl_ca_certs',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'oslo_messaging_rabbit/kombu_ssl_certfile':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/kombu_ssl_certfile',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'oslo_messaging_rabbit/kombu_ssl_keyfile':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/kombu_ssl_keyfile',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'oslo_messaging_rabbit/kombu_ssl_version':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/kombu_ssl_version',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'oslo_messaging_rabbit/rabbit_ha_queues':
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/rabbit_ha_queues',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'true',
}

sahara_config { 'oslo_messaging_rabbit/rabbit_hosts':
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/rabbit_hosts',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '10.108.2.4:5673, 10.108.2.6:5673, 10.108.2.5:5673',
}

sahara_config { 'oslo_messaging_rabbit/rabbit_login_method':
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/rabbit_login_method',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'AMQPLAIN',
}

sahara_config { 'oslo_messaging_rabbit/rabbit_max_retries':
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/rabbit_max_retries',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '0',
}

sahara_config { 'oslo_messaging_rabbit/rabbit_password':
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/rabbit_password',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  secret => 'true',
  value  => 'U7sRLche',
}

sahara_config { 'oslo_messaging_rabbit/rabbit_retry_backoff':
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/rabbit_retry_backoff',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '2',
}

sahara_config { 'oslo_messaging_rabbit/rabbit_retry_interval':
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/rabbit_retry_interval',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '1',
}

sahara_config { 'oslo_messaging_rabbit/rabbit_use_ssl':
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/rabbit_use_ssl',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'false',
}

sahara_config { 'oslo_messaging_rabbit/rabbit_userid':
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/rabbit_userid',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => 'nova',
}

sahara_config { 'oslo_messaging_rabbit/rabbit_virtual_host':
  before => 'Exec[sahara-dbmanage]',
  name   => 'oslo_messaging_rabbit/rabbit_virtual_host',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
  value  => '/',
}

sahara_config { 'ssl/ca_file':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'ssl/ca_file',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'ssl/cert_file':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'ssl/cert_file',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

sahara_config { 'ssl/key_file':
  ensure => 'absent',
  before => 'Exec[sahara-dbmanage]',
  name   => 'ssl/key_file',
  notify => ['Service[sahara-api]', 'Service[sahara-engine]'],
}

service { 'sahara-api':
  ensure     => 'running',
  before     => 'Haproxy_backend_status[sahara]',
  enable     => 'true',
  hasrestart => 'true',
  hasstatus  => 'true',
  name       => 'sahara-api',
  require    => 'Package[sahara-api]',
  tag        => 'sahara-service',
}

service { 'sahara-engine':
  ensure     => 'running',
  enable     => 'true',
  hasrestart => 'true',
  hasstatus  => 'true',
  name       => 'sahara-engine',
  require    => 'Package[sahara-engine]',
  tag        => 'sahara-service',
}

stage { 'main':
  name => 'main',
}

tweaks::ubuntu_service_override { 'sahara-api':
  name         => 'sahara-api',
  package_name => 'sahara',
  service_name => 'sahara-api',
}

