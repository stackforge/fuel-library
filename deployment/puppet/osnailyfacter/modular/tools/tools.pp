notice('MODULAR: tools.pp')

$atop_hash     = hiera('atop', {})
$atop_enabled  = pick($atop_hash['service_enabled'], true)
$atop_interval = pick($atop_hash['interval'], 20)
$atop_rotate   = pick($atop_hash['rotate'], 7)

$custom_acct_file = hiera('custom_accounting_file', undef)

class { 'osnailyfacter::atop':
  service_enabled  => $atop_enabled,
  interval         => $atop_interval,
  rotate           => $atop_rotate,
  custom_acct_file => $custom_acct_file,
}

class { 'osnailyfacter::ssh': }

if $::virtual != 'physical' {
  class { 'osnailyfacter::acpid': }
}

$tools = [
  'screen',
  'tmux',
  'htop',
  'tcpdump',
  'strace',
  'fuel-misc',
  'man-db',
]

package { $tools :
  ensure => 'present',
}

package { 'cloud-init':
  ensure => 'absent',
}

if $::osfamily == 'Debian' {
  apt::conf { 'notranslations':
    ensure        => 'present',
    content       => 'Acquire::Languages "none";',
    notify_update => false,
  }
}

$puppet = hiera('puppet')
class { 'osnailyfacter::puppet_pull':
  modules_source   => $puppet['modules'],
  manifests_source => $puppet['manifests'],
}

$deployment_mode = hiera('deployment_mode')
