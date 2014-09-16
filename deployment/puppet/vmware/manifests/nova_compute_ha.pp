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
#
# This type creates nova-compute service for provided vSphere
# cluster (cluster that is formed of ESXi hosts and is managed by vCenter
# server).

define vmware::nova_compute_ha(
  $amqp_port = '5673',
  $api_retry_count = 5,
  $compute_driver = 'vmwareapi.VMwareVCDriver',
  $maximum_objects = 100,
  $nova_conf = '/etc/nova/nova.conf',
  $nova_conf_dir = '/etc/nova/nova-compute.d/',
  $task_poll_interval = 5.0,
  $use_linked_clone = true,
  $wsdl_location = undef
)
{
  # We expect that resource $name contains vSphere cluster name, e.g. 'Cluster1'
  $nova_compute_conf = "$nova_conf_dir/vcenter-${name}.conf"

  File[$nova_conf_dir]->
  File["${nova_compute_conf}"]->
  Cs_resource["p_vcenter_nova_compute_${name}"]->
  Service["p_vcenter_nova_compute_${name}"]

  if !defined(File[$nova_conf_dir]) {
    file { $nova_conf_dir:
      ensure => directory,
      owner  => 'nova',
      group  => 'nova',
      mode   => '0750'
    }
  }


  file { "${nova_compute_conf}":
    content => template("vmware/nova-compute-ha.conf.erb"),
    mode    => '0600',
    owner   => 'nova',
    group   => 'nova',
    ensure  => present,
  }

  cs_resource { "p_vcenter_nova_compute_${name}":
    ensure          => present,
    primitive_class => 'ocf',
    provided_by     => 'mirantis',
    primitive_type  => 'nova-compute',
    metadata        => {
      resource-stickiness => '1'
    },
    parameters      => {
      amqp_server_port      => $amqp_port,
      config                => $nova_conf,
      pid                   => "/var/run/nova/nova-compute-${name}.pid",
      additional_parameters => "--config-file=${nova_compute_conf}",
    },
    operations      => {
      monitor  => {
        interval => '20',
        timeout  => '10',
      },
        start  => {
        timeout => '30',
      },
        stop   => {
        timeout => '30',
      }
    }
  }

  service { "p_vcenter_nova_compute_${name}":
    ensure => running,
    enable => true,
    provider => 'pacemaker',
  }
}
