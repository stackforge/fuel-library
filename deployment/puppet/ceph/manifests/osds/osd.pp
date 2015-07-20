# == Define: ceph::osds::osd
#
# Prepare and activate OSD nodes on the node
#
# === Parameters
#
# [*use_prepared_devices*]
# (required) Boolean. If true, the device assumed to be prepared in advance and
# 'ceph-deploy prepare' will be skipped for the device.
#
define ceph::osds::osd (
  $use_prepared_devices,
) {

  # ${name} format is DISK[:JOURNAL]
  $params             = split($name, ':')
  $data_device_name   = $params[0]
  $deploy_device_name = "${::hostname}:${name}"

  unless $use_prepared_devices {
    exec { "ceph-deploy osd prepare ${deploy_device_name}":
      # ceph-deploy osd prepare is ensuring there is a filesystem on the
      # disk according to the args passed to ceph.conf (above).
      #
      # It has a long timeout because of the format taking forever. A
      # resonable amount of time would be around 300 times the length of
      # $osd_nodes. Right now its 0 to prevent puppet from aborting it.
      command   => "ceph-deploy osd prepare ${deploy_device_name}",
      returns   => 0,
      timeout   => 0, # TODO: make this something reasonable
      tries     => 2, # This is necessary because of race for mon creating keys
      try_sleep => 1,
      logoutput => true,
      unless    => "ceph-disk list | grep -q '${data_device_name} .*ceph data, active'",
    } -> Exec["ceph-deploy osd activate ${deploy_device_name}"]
  }

  exec { "ceph-deploy osd activate ${deploy_device_name}":
    command   => "ceph-deploy osd activate ${deploy_device_name}",
    try_sleep => 10,
    tries     => 3,
    logoutput => true,
    timeout   => 0,
    onlyif    => "ceph-disk list | grep -q '${data_device_name} .*ceph data, prepared'",
  }

}
