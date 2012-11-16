node /^puppet\d.spence.org.uk.local$/ {

  $config = hiera_hash('config')

  class { 'pe_apacheha::puppetmaster':
    config => $config,
  }

  ini_setting {'puppetserverreporturl':
    ensure  => present,
    setting => 'reporturl',
    value   => "https://${config[reportserver]}/reports/upload",
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'agent',
  }

  ini_setting {'puppetagentmaster':
    ensure  => present,
    setting => 'server',
    value   => 'puppetha.spence.org.uk.local',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'agent',
    notify  => Service['pe-httpd'],
  }
  service { "pe-puppet":
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    restart => 'echo service pe-puppet restart | at now+5min',
    notify  => Service['pe-httpd'],
  }

}

node /puppetha/ {

  $config = hiera_hash('config')

  class { 'pe_apacheha':
    config => $config,
  }

  $config = hiera_hash('config')

  class { 'pe_lvs::frontend':
    confighash => $config,
  }

}

node /lvsfe/ inherits default {
  $config = hiera_hash('config')

  class { 'pe_lvs':
    confighash => $config,
  }

  host { 'puppetha.spence.org.uk.local':
    ip => '192.168.0.122',
  }
}
