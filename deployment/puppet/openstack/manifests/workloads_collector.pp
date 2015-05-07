# == Class: openstack::workloads_collector
#
# Creates a keystone user to connect workload statistics
# from a running OpenStack environment.
#
# === Parameters
#
# [*workloads_password*]
#   (required) Password.
# [*enabled*]
#   (optional) Creates the user. Defaults to true.
# [*workloads_user*]
#   (optional) Defaults to 'workloads_collector'.
# [*tenant*]
#   (optional) Defaults to 'services'.
#
class openstack::workloads_collector(
  $workloads_password = false,
  $enabled            = true,
  $workloads_username = 'workloads_collector',
  $workloads_tenant   = 'services',
  $workloads_create_user = false
) {

  validate_string($workloads_password)

  if $workloads_create_user {
    $ensure_create_user = present
  } else {
    $ensure_create_user = absent
  }

  keystone_user { $workloads_username:
    ensure          => $ensure_create_user,
    password        => $workloads_password,
    enabled         => $enabled,
    tenant          => $workloads_tenant,
  }

  keystone_user_role { "$workloads_username@$workloads_tenant":
    ensure => $ensure_create_user,
    roles  => ['admin'],
  }
}
