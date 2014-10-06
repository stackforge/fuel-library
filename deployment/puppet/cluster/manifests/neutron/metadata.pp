# not a doc string

class cluster::neutron::metadata (
  $primary = false,
  ) {

  require cluster::neutron

  cluster::corosync::cs_service {'neutron-metadata-agent':
    ocf_script          => 'neutron-agent-metadata',
    csr_multistate_hash => { 'type' => 'clone' },
    csr_ms_metadata     => { 'interleave' => 'true' },
    csr_mon_intr        => '60',
    csr_mon_timeout     => '10',
    csr_timeout         => '30',
    service_name        => $::neutron::params::metadata_agent_service,
    package             => $::neutron::params::metadata_agent_package,
    service_title       => 'neutron-metadata',
    primary             => $primary,
  }
}
