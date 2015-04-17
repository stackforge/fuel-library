class openstack::corosync (
  $bind_address          = '127.0.0.1',
  $multicast_address     = '239.1.1.2',
  $secauth               = false,
  $stonith               = false,
  $quorum_policy         = 'ignore',
  $expected_quorum_votes = '2',
  $unicast_addresses     = undef,
  $corosync_version      = '1',
  $packages              = ['corosync', 'pacemaker'],
) {

  file { 'limitsconf':
    ensure  => present,
    path    => '/etc/security/limits.conf',
    source  => 'puppet:///modules/openstack/limits.conf',
    replace => true,
    owner   => '0',
    group   => '0',
    mode    => '0644',
    before  => Service['corosync'],
  }

  anchor {'corosync':}

  Anchor['corosync'] -> Cs_property<||>

  Class['::corosync']->Cs_shadow<||>
  Class['::corosync']->Cs_property<||>->Cs_resource<||>
  Cs_property<||>->Cs_shadow<||>

  Cs_property['no-quorum-policy']->
    Cs_property['stonith-enabled']->
      Cs_property['start-failure-is-fatal']

  if $corosync_version == '2' {
    $version_real = '1'
  } else {
    $version_real = '0'
  }

  corosync::service { 'pacemaker':
    version => $version_real,
  }

  Anchor['corosync'] -> Corosync::Service['pacemaker']
  Corosync::Service['pacemaker'] ~> Service['corosync']
  Corosync::Service['pacemaker'] -> Anchor['corosync-done']


  class { '::corosync':
    enable_secauth    => $secauth,
    bind_address      => $bind_address,
    multicast_address => $multicast_address,
    unicast_addresses => $unicast_addresses,
    corosync_version  => $corosync_version,
    packages          => $packages,
    # NOTE(bogdando) debug is *too* verbose
    debug             => false,
  } -> Anchor['corosync-done']

  # NOTE(bogdando) #LP1445478 - lower the validator version for Ubuntu
  if ($::osfamily == 'Debian') {
    # Use retries as CIB require some time to become ready
    exec { 'fix-crm-validator':
      command   => 'cibadmin --modify --xml-text \'<cib validate-with="pacemaker-1.2"/>\'',
      path      => '/bin:/usr/bin/:/sbin:/usr/sbin',
      tries     => 10,
      try_sleep => 30,
      before    => Anchor['corosync-done'],
    } -> Anchor['corosync-done']

    Class['::corosync'] -> Exec['fix-crm-validator']
    Exec['fix-crm-validator'] -> Cs_property<||>
  }

  Cs_property {
    ensure   => present,
    provider => 'crm',
  }

  cs_property { 'no-quorum-policy':
    value   => $quorum_policy,
  } -> Anchor['corosync-done']

  cs_property { 'stonith-enabled':
    value  => $stonith,
  } -> Anchor['corosync-done']

  cs_property { 'start-failure-is-fatal':
    value  => false,
  } -> Anchor['corosync-done']

  cs_property { 'symmetric-cluster':
    value  => false,
  } -> Anchor['corosync-done']

  anchor {'corosync-done':}
}
