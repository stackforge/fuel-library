class zabbix::agent::scripts inherits zabbix::params {

  file { 'agent-scripts':
    ensure    => directory,
    path      => $agent_scripts,
    recurse   => true,
    purge     => true,
    force     => true,
    mode      => '0755',
    source    => 'puppet:///modules/zabbix/scripts',
  }

  file { '/etc/zabbix/check_api.conf':
    ensure      => present,
    content     => template('zabbix/check_api.conf.erb'),
  }

  file { '/etc/zabbix/check_rabbit.conf':
    ensure      => present,
    content     => template('zabbix/check_rabbit.conf.erb'),
  }

  file { '/etc/zabbix/check_db.conf':
    ensure      => present,
    content     => template('zabbix/check_db.conf.erb'),
  }

  file { '/etc/sudoers.d':
    ensure => directory,
  }

  file { 'zabbix_no_requiretty':
    path   => '/etc/sudoers.d/zabbix',
    mode   => '0440',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/zabbix/zabbix-sudo',
  }

  if ! defined(Package['sudo']) {
    package { 'sudo':
      ensure => installed,
    }
  }

  File[$agent_scripts] -> Zabbix::Agent::Userparameter <||>
}
