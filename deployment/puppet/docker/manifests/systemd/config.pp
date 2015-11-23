define docker::systemd::config( $release, $depends, $timeout ) {
  file { "/usr/lib/systemd/system/docker-${title}.service":
    ensure  => file,
    content => template('docker/systemd/template.service.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => [ Exec["systemd_reload_${title}"], Exec["enable_${title}_container"] ]
  }

  exec { "reload_systemd_${title}":
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }
  ->
  # Do not use service provider, because we need just
  # enable service without any insurances
  exec { "enable_${title}_container":
    command     => "/usr/bin/systemctl enable docker-${title}.service",
    refreshonly => true,
  }
}
