class pe_apacheha::nfs ($config) {

  $puppetmasters = $config['pe_apacheha_puppetmasters']

  if $::fqdn == $config['certserver'] {

    $modulepath = $settings::modulepath
    $manifestdir = $settings::manifestdir
    file { '/etc/exports':
      ensure => present,
      content => template('pe_apacheha/exports.erb'),
      notify  => Service['nfs'],
    }
    service { 'rpcbind':
      ensure => running,
      enable => true,
    } ->
    service { 'nfs':
      ensure => running,
      enable => true,
      restart => 'service nfs reload',
    } ~> 
    service { 'nfslock':
      ensure => running,
      enable => true,
      subscribe => Service['nfs'],
    }
  } else {

    service { 'rpcbind':
      ensure => running,
      enable => true,
    }
  
    mount { "/etc/puppetlabs/puppet/modules":
      device  => "${config['certserver']}:/etc/puppetlabs/puppet/modules",
      fstype  => "nfs",
      ensure  => "mounted",
      options => "ro",
      atboot  => true,
    }
    mount { "/etc/puppetlabs/hieradata":
      device  => "${config['certserver']}:/etc/puppetlabs/hieradata",
      fstype  => "nfs",
      ensure  => "mounted",
      options => "ro",
      atboot  => true,
    }
    mount { "/etc/puppetlabs/puppet/ssl":
      device  => "${config['certserver']}:/etc/puppetlabs/ssl",
      fstype  => "nfs",
      ensure  => "mounted",
      options => "rw",
      atboot  => true,
    }
    mount { "/etc/puppetlabs/puppet/manifests":
      device  => "${config['certserver']}:/etc/puppetlabs/puppet/manifests",
      fstype  => "nfs",
      ensure  => "mounted",
      options => "ro",
      atboot  => true,
    }

  }

}
