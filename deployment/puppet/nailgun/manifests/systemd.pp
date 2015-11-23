# == Class: nailgun::systemd
#
# Apply local settings for nailgun services.
#
# At this moment only start/stop timeouts
# and syslog identificators.
#
# === Parameters
#
# [*services*]
#   (required) Array. This is an array of service names for which local
#   changes well be applied.
#
# [*production*]
#   (required) String. Determine environment.
#   Changes applies only for 'prod' and 'docker' environments.
#

class nailgun::systemd (
  $services = [],
  $production
) {

case $production {
  'prod', 'docker': {
    if !empty($services) {
      nailgun::systemd::config { $services: }
    }
  }
  default: { }
}

}
