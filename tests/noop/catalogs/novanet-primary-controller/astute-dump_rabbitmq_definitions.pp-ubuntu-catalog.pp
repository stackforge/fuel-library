class { 'Settings':
  name => 'Settings',
}

class { 'main':
  name => 'main',
}

exec { 'rabbitmq-dump-definitions':
  command => 'curl -u nova:zrMvquYX http://localhost:15672/api/definitions -o /etc/rabbitmq/definitions',
  path    => ['/usr/bin', '/usr/sbin', '/sbin', '/bin'],
}

file { '/etc/rabbitmq/definitions':
  ensure => 'file',
  group  => 'root',
  mode   => '0600',
  owner  => 'root',
  path   => '/etc/rabbitmq/definitions',
}

stage { 'main':
  name => 'main',
}

