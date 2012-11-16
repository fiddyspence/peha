class pe_apacheha::puppetmaster ($config) {
  
  $pe_apacheha_certname = $settings::certname
  $pe_apacheca_allowfrom = $config['pe_apacheca_allowfrom']

  file { '/etc/puppetlabs/httpd/conf.d/puppetmaster.conf':
     ensure => present,
     content => template('pe_apacheha/puppetmaster.conf.erb'),
     owner => 'root',
     group => 'pe-puppet',
     mode => '0644',
     notify => Service['pe-httpd'],
  }
  
  service { 'pe-httpd':
    ensure => running,
    enable => true,
    restart => 'echo service pe-httpd restart | at now+1min',
  }

  if $config['hackreplication'] {

    class {'pe_apacheha::nfs':
      config => $config,
    }

  }


}
