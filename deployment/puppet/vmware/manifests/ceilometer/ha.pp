#    Copyright 2014 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

# Variables:
#   node_fqdn - used in erb template

define vmware::ceilometer::ha (
  $index,
  $node_fqdn,
  $amqp_port = '5673',
  $ceilometer_config   = '/etc/ceilometer/ceilometer.conf',
  $ceilometer_conf_dir = '/etc/ceilometer/ceilometer-compute.d',
) {
  $ceilometer_compute_conf = "${ceilometer_conf_dir}/vmware-${index}.conf"

  if ! defined(File[$ceilometer_conf_dir]) {
    file { $ceilometer_conf_dir:
      ensure => directory,
      owner  => 'ceilometer',
      group  => 'ceilometer',
      mode   => '0750'
    }
  }

  $cluster = $name
  if ! defined(File[$ceilometer_compute_conf]) {
    file { $ceilometer_compute_conf:
      ensure  => present,
      content => template('vmware/ceilometer-compute.conf.erb'),
      mode    => '0600',
      owner   => 'ceilometer',
      group   => 'ceilometer',
    }
  }

  cs_resource { "p_ceilometer_agent_compute_vmware_${index}":
    ensure          => present,
    primitive_class => 'ocf',
    provided_by     => 'mirantis',
    primitive_type  => 'ceilometer-agent-compute',
    metadata        => {
      'target-role' => 'stopped',
      'resource-stickiness' => '1'
    },
    parameters      => {
      amqp_server_port      => $amqp_port,
      config                => $ceilometer_config,
      pid                   => "/var/run/ceilometer/ceilometer-agent-compute-${index}.pid",
      user                  => "ceilometer",
      additional_parameters => "--config-file=${ceilometer_compute_conf}",
    },
    operations      => {
      monitor  => { timeout => '20', interval => '30' },
      start    => { timeout => '360' },
      stop     => { timeout => '360' }
    }
  }

  service { "p_ceilometer_agent_compute_vmware_${index}":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => 'pacemaker',
  }

  File["${ceilometer_conf_dir}"]->
  File["${ceilometer_compute_conf}"]->
  Cs_resource["p_ceilometer_agent_compute_vmware_${index}"]->
  Service["p_ceilometer_agent_compute_vmware_${index}"]
}
