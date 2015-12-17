# Configure apache MPM
class osnailyfacter::apache_mpm {

  # Performance optimization for Apache mpm
  if $::memorysize_mb < 4100 {
    $maxclients = 100
  } else {
    $maxclients = inline_template('<%= Integer(@memorysize_mb.to_i / 10) %>')
  }

  if $::processorcount <= 2 {
    $startservers = 2
  } else {
    $startservers = $::processorcount
  }

  $maxrequestsperchild = 0
  $threadsperchild     = 25
  $minsparethreads     = 25
  $serverlimit         = inline_template('<%= Integer(@maxclients.to_i / @threadsperchild.to_i) %>')
  $maxsparethreads     = inline_template('<%= Integer(@maxclients.to_i / 2) %>')

  # Define apache mpm
  if $::osfamily == 'RedHat' {
    $mpm_module = 'event'
  } else {
    $mpm_module = 'worker'
  }

  tidy { "remove-distro-mpm-modules":
    path    => $::apache::params::mod_enable_dir,
    recurse => true,
    matches => [ '*mpm*' ],
    rmdirs  => false,
  } ->
  class { "::apache::mod::$mpm_module":
    startservers        => $startservers,
    maxclients          => $maxclients,
    minsparethreads     => $minsparethreads,
    maxsparethreads     => $maxsparethreads,
    threadsperchild     => $threadsperchild,
    maxrequestsperchild => $maxrequestsperchild,
    serverlimit         => $serverlimit,
  }

  Class['osnailyfacter::apache'] -> Class['osnailyfacter::apache_mpm'] ~> Service<| title == 'httpd' |>

}
