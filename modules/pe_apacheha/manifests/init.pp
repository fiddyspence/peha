# == Class: pe_apacheha
#
# Full description of class pe_apacheha here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { pe_apacheha:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2011 Your name here, unless otherwise noted.
#
class pe_apacheha ($config) {

  $puppetmasters = $config['pe_apacheha_puppetmasters']

  anchor { 'pe_apacheha::begin': }

  class { 'apache':
    require => Anchor['pe_apacheha::begin'],
  }
  class { 'apache::mod::ssl':
    before  => Anchor['pe_apacheha::end'],
  }

  anchor { 'pe_apacheha::end':
    require => Anchor['pe_apacheha::begin'],
  }

  file { "${apache::params::httpd_dir}/ssl":
    ensure => directory,
    require => Package['httpd'],
  }
  file { "${apache::params::httpd_dir}/ssl/ca":
    ensure => directory,
    require => Package['httpd'],
  }
  file { "${apache::params::httpd_dir}/ssl/private_keys":
    ensure => directory,
    require => Package['httpd'],
  }

  file { "${apache::params::httpd_dir}/ssl/puppet_public_key.pem":
    ensure => file,
    source => "puppet:///modules/${module_name}/puppet_public_key.pem",
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    notify  => Service['httpd']
  }
  file { "${apache::params::httpd_dir}/ssl/private_keys/puppet_private_key.pem":
    ensure => file,
    source => "puppet:///modules/${module_name}/puppet_private_key.pem",
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    notify  => Service['httpd']
  }
  file { "${apache::params::httpd_dir}/ssl/ca_key.pem":
    ensure => file,
    source => "puppet:///modules/${module_name}/ca_key.pem",
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    notify  => Service['httpd']
  }
  file { "${apache::params::httpd_dir}/ssl/ca/ca_crt.pem":
    ensure => file,
    source => "puppet:///modules/${module_name}/ca_crt.pem",
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    notify  => Service['httpd']
  }

  $cacrl = file("${settings::cacrl}")
  file { "${apache::params::httpd_dir}/ssl/ca/ca_crl.pem":
    ensure => file,
    content => $cacrl,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    notify  => Service['httpd']
  }
  file { "${apache::params::vdir}/puppetmaster.conf":
    ensure  => file,
    content => template("${module_name}/loadbalance.conf.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['httpd']
  }
  
  sysctl { 'net.ipv4.conf.eth0.arp_ignore':
    value => 1,
    permanent => 'yes',
  }
  sysctl { 'net.ipv4.conf.eth0.arp_announce':
    value => 2,
    permanent => 'yes',
  }
}
