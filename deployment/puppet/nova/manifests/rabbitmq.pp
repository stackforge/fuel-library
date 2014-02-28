#
# class for installing rabbitmq server for nova
#
#
class nova::rabbitmq(
  $userid='guest',
  $password='guest',
  $port='5672',
  $virtual_host='/',
  $cluster = false,
  $cluster_nodes = [], #Real node names to install RabbitMQ server onto.
  $enabled = true,
  $rabbit_node_ip_address = 'UNSET',
  $ha_mode = false,
  $primary_controller = false
) {

  # only configure nova after the queue is up
  Class['rabbitmq::service'] -> Anchor<| title == 'nova-start' |>

  if ($enabled) {
    if $userid == 'guest' {
      $delete_guest_user = false
    } else {
      $delete_guest_user = true
    }
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  class { 'rabbitmq::server':
    service_ensure     => $service_ensure,
    port               => $port,
    delete_guest_user  => $delete_guest_user,
    config_cluster     => $cluster,
    cluster_disk_nodes => $cluster_nodes,
    version            => $::openstack_version['rabbitmq_version'],
    node_ip_address    => $rabbit_node_ip_address,
  }

  if ($enabled) {
    rabbitmq_vhost { $virtual_host:
      provider => 'rabbitmqctl',
      require => Class['rabbitmq::server'],
    }
  }

  if ($ha_mode) {
    # OCF script for pacemaker
    # and his dependences
    file {'rabbitmq-ocf':
      path   =>'/usr/lib/ocf/resource.d/mirantis/rabbitmq-server',
      mode   => '0755',
      owner  => root,
      group  => root,
      source => "puppet:///modules/nova/ocf/rabbitmq",
    }

    Service['rabbitmq-server'] -> File['rabbitmq-ocf']
    Package['pacemaker'] -> File['rabbitmq-ocf']
    File<| title == 'ocf-mirantis-path' |> -> File['rabbitmq-ocf']
    File['rabbitmq-ocf'] -> Cs_resource<| title == "p_rabbitmq-server" |>

    if ($primary_controller) {
      cs_resource { "p_rabbitmq-server":
        ensure          => present,
        #cib             => 'rabbitmq',
        primitive_class => 'ocf',
        provided_by     => 'mirantis',
        primitive_type  => 'rabbitmq-server',
        parameters      => {
          'debug'         => false,
          'service_name'  => 'rabbitmq-server',
          'node_port'     => $port,
        },
        multistate_hash => {
          'type' => 'master',
        },
        ms_metadata => {
          'notify'      => 'true',
          'ordered'     => 'true',
          'interleave'  => 'true',
          'master-max'  => '1',
          'master-node-max' => '1',
          'target-role' => 'Master'
        },
        operations => {
          'monitor' => {
            'interval' => '10',
            'timeout'  => '60'
          },
          'monitor:Master' => { # name:role
            'role' => 'Master',
            'interval' => '7', # should be non-intercectable with interval from ordinary monitor
            'timeout'  => '60'
          },
          'start' => {
            'timeout' => '60'
          },
          'stop' => {
            'timeout' => '60'
          },
          'promote' => {
            'timeout' => '60'
          },
          'demote' => {
            'timeout' => '60'
          },
          'notify' => {
            'timeout' => '60'
          },
        },
      }
      # exec {'rmq-co-location': # Don't use INFINITI in co-location for prevent go down VIP-resource while Rabbitmq not running.
      #   path     => "/sbin:/bin:/usr/sbin:/usr/bin",
      #   command  => "pcs constraint colocation add vip__management_old with master master_p_rabbitmq-server 10000",
      #   onlyif   => [ "pcs resource show p_rabbitmq-server", "pcs resource show vip__management_old"],
      #   unless   => "pcs constraint | grep 'vip__management_old with master_p_rabbitmq-server'",
      #   provider => "shell",
      # }
    }

    File['rabbitmq-ocf'] -> Exec['cleanup_rmq_resource']
    Cs_resource<| title == 'p_rabbitmq-server' |> -> Exec['cleanup_rmq_resource']
    exec {'cleanup_rmq_resource':
      path     => "/sbin:/bin:/usr/sbin:/usr/bin",
      command  => "sleep 20 ; crm_resource --cleanup --node=$::l3_fqdn_hostname --resource=p_rabbitmq-server",
      returns  => [0,1,""],
      provider => "shell",
    }
  }

}
