class { 'Cluster::Dns_ocf':
  name               => 'Cluster::Dns_ocf',
  primary_controller => 'false',
}

class { 'Osnailyfacter::Dnsmasq':
  before                 => 'Class[Cluster::Dns_ocf]',
  external_dns           => ['8.8.8.8', '8.8.4.4'],
  management_vrouter_vip => '192.168.0.3',
  master_ip              => '10.108.0.2',
  name                   => 'Osnailyfacter::Dnsmasq',
}

class { 'Settings':
  name => 'Settings',
}

class { 'main':
  name => 'main',
}

file { '/etc/dnsmasq.d/dns.conf':
  ensure  => 'present',
  content => 'domain=pp
server=/pp/10.108.0.2
resolv-file=/etc/resolv.dnsmasq.conf
bind-interfaces
listen-address=192.168.0.3
',
  path    => '/etc/dnsmasq.d/dns.conf',
}

file { '/etc/dnsmasq.d':
  ensure => 'directory',
  path   => '/etc/dnsmasq.d',
}

file { '/etc/resolv.dnsmasq.conf':
  ensure  => 'present',
  before  => 'File[/etc/dnsmasq.d/dns.conf]',
  content => 'nameserver 8.8.8.8
nameserver 8.8.4.4
',
  path    => '/etc/resolv.dnsmasq.conf',
}

package { 'dnsmasq-base':
  ensure => 'present',
  name   => 'dnsmasq-base',
}

service { 'p_dns':
  ensure     => 'running',
  enable     => 'true',
  hasrestart => 'true',
  hasstatus  => 'true',
  name       => 'p_dns',
  provider   => 'pacemaker',
}

stage { 'main':
  name => 'main',
}

