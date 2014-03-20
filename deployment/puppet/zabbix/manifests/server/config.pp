class zabbix::server::config {

  include zabbix::params

  zabbix_hostgroup { $zabbix::params::host_groups:
    ensure => present,
    api    => $zabbix::params::api_hash,
  }

  file { '/etc/zabbix/import':
    ensure    => directory,
    recurse   => true,
    purge     => true,
    force     => true,
    source    => 'puppet:///modules/zabbix/import'
  }

  Zabbix_configuration_import { require  => File['/etc/zabbix/import'] }

  zabbix_configuration_import { 'Template_App_Zabbix_Agent.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_Zabbix_Agent.xml',
    api => $zabbix::params::api_hash,
  }

  zabbix_configuration_import { 'Template_Fuel_OS_Linux.xml Import':
    ensure   => present,
    api => $zabbix::params::api_hash,
    xml_file => '/etc/zabbix/import/Template_Fuel_OS_Linux.xml',
  }

  # Nova templates
  zabbix_configuration_import { 'Template_App_OpenStack_Nova_API_EC2.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_API_EC2.xml',
    api => $zabbix::params::api_hash,
  }
  zabbix_configuration_import { 'Template_App_OpenStack_Nova_API.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_API.xml',
    api => $zabbix::params::api_hash,
  }
  zabbix_configuration_import { 'Template_App_OpenStack_Nova_API_Metadata.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_API_Metadata.xml',
    api => $zabbix::params::api_hash,
  }
  zabbix_configuration_import { 'Template_App_OpenStack_Nova_API_OSAPI.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_API_OSAPI.xml',
    api => $zabbix::params::api_hash,
  }
  zabbix_configuration_import { 'Template_App_OpenStack_Nova_API_OSAPI_check.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_API_OSAPI_check.xml',
    api => $zabbix::params::api_hash,
  }
  zabbix_configuration_import { 'Template_App_OpenStack_Nova_Cert.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_Cert.xml',
    api => $zabbix::params::api_hash,
  }
  zabbix_configuration_import { 'Template_App_OpenStack_Nova_ConsoleAuth.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_ConsoleAuth.xml',
    api => $zabbix::params::api_hash,
  }
  zabbix_configuration_import { 'Template_App_OpenStack_Nova_Scheduler.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_Scheduler.xml',
    api => $zabbix::params::api_hash,
  }
  zabbix_configuration_import { 'Template_App_OpenStack_Nova_Compute.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_Compute.xml',
    api => $zabbix::params::api_hash,
  }
  zabbix_configuration_import { 'Template_App_OpenStack_Libvirt.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Libvirt.xml',
    api => $zabbix::params::api_hash,
  }
  zabbix_configuration_import { 'Template_App_OpenStack_Nova_Network.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_Network.xml',
    api => $zabbix::params::api_hash,
  }
}
