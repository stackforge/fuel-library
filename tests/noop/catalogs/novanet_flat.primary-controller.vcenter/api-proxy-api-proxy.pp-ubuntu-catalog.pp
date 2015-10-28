apache::vhost { 'apache_api_proxy':
  ensure               => 'present',
  access_log           => 'true',
  access_log_env_var   => 'false',
  access_log_file      => 'false',
  access_log_format    => 'false',
  access_log_pipe      => 'false',
  access_log_syslog    => 'false',
  add_listen           => 'true',
  additional_includes  => [],
  apache_version       => '2.4',
  block                => [],
  custom_fragment      => '  ProxyRequests on
  ProxyVia On
  AllowCONNECT 443 563 5000 8000 8003 8004 8080 8082 8386 8773 8774 8776 8777 9292 9696
  HostnameLookups off
  LimitRequestFieldSize 81900
  <Proxy *>
    Order Deny,Allow
        Allow from 10.108.0.2
        Deny from all
  </Proxy>
',
  default_vhost        => 'false',
  directoryindex       => '',
  docroot              => '/var/www/html',
  docroot_group        => 'root',
  docroot_owner        => 'root',
  error_documents      => [],
  error_log            => 'true',
  error_log_syslog     => 'syslog:local0',
  ip_based             => 'false',
  log_level            => 'notice',
  logroot              => '/var/log/apache2',
  logroot_ensure       => 'directory',
  manage_docroot       => 'true',
  name                 => 'apache_api_proxy',
  no_proxy_uris        => [],
  no_proxy_uris_match  => [],
  options              => ['Indexes', 'FollowSymLinks', 'MultiViews'],
  override             => 'None',
  php_admin_flags      => {},
  php_admin_values     => {},
  php_flags            => {},
  php_values           => {},
  port                 => '8888',
  proxy_error_override => 'false',
  proxy_preserve_host  => 'false',
  redirect_source      => '/',
  scriptaliases        => [],
  serveraliases        => [],
  servername           => 'apache_api_proxy',
  setenv               => [],
  setenvif             => [],
  ssl                  => 'false',
  ssl_cert             => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  ssl_certs_dir        => '/etc/ssl/certs',
  ssl_key              => '/etc/ssl/private/ssl-cert-snakeoil.key',
  ssl_proxyengine      => 'false',
  suphp_addhandler     => 'x-httpd-php',
  suphp_configpath     => '/etc/php5/apache2',
  suphp_engine         => 'off',
  vhost_name           => '*',
  virtual_docroot      => 'false',
}

class { 'Apache':
  apache_name            => 'apache2',
  apache_version         => '2.4',
  conf_dir               => '/etc/apache2',
  conf_template          => 'apache/httpd.conf.erb',
  confd_dir              => '/etc/apache2/conf.d',
  default_confd_files    => 'true',
  default_mods           => 'true',
  default_ssl_cert       => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  default_ssl_key        => '/etc/ssl/private/ssl-cert-snakeoil.key',
  default_ssl_vhost      => 'false',
  default_type           => 'none',
  default_vhost          => 'false',
  docroot                => '/var/www',
  error_documents        => 'false',
  group                  => 'www-data',
  httpd_dir              => '/etc/apache2',
  keepalive              => 'Off',
  keepalive_timeout      => '15',
  lib_path               => '/usr/lib/apache2/modules',
  log_formats            => {},
  log_level              => 'warn',
  logroot                => '/var/log/apache2',
  manage_group           => 'true',
  manage_user            => 'true',
  max_keepalive_requests => '100',
  mod_dir                => '/etc/apache2/mods-available',
  mod_enable_dir         => '/etc/apache2/mods-enabled',
  mpm_module             => 'false',
  name                   => 'Apache',
  package_ensure         => 'installed',
  ports_file             => '/etc/apache2/ports.conf',
  purge_configs          => 'false',
  purge_vdir             => 'false',
  sendfile               => 'On',
  server_root            => '/etc/apache2',
  server_signature       => 'Off',
  server_tokens          => 'Prod',
  serveradmin            => 'root@localhost',
  servername             => 'node-1',
  service_enable         => 'true',
  service_ensure         => 'running',
  service_manage         => 'true',
  service_name           => 'apache2',
  timeout                => '120',
  trace_enable           => 'Off',
  use_optional_includes  => 'false',
  user                   => 'www-data',
  vhost_dir              => '/etc/apache2/sites-available',
  vhost_enable_dir       => '/etc/apache2/sites-enabled',
}

firewall { '007 tinyproxy':
  action => 'accept',
  dport  => '8888',
  name   => '007 tinyproxy',
  proto  => 'tcp',
  source => '10.108.0.2',
}

