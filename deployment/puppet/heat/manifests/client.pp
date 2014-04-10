#
# Installs the heat python library.
#
# == parameters
#  [*ensure*]
#    ensure state for pachage.
#
class heat::client (
  $ensure = 'present'
) {

  include heat::params

  package { 'python-routes':
    ensure  => $ensure,
    name    => $::heat::params::deps_routes_package_name,
  } ->
  package { 'python-heatclient':
    ensure  => $ensure,
    name    => $::heat::params::client_package_name,
  }

}
