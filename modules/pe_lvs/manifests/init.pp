# == Class: pe_lvs
#
# Full description of class pe_lvs here.
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
#  class { pe_lvs:
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
class pe_lvs ($confighash) {

  if ! ($::osfamily =~ /RedHat/ ) {
    notify { "your $::operatingsystem won't run this module - sorry":}
    fail('pe_lvs: unsupported os')
  }

  package { ['piranha','ipvsadm']:
    ensure => present,
  }
  sysctl { 'net.ipv4.ip_forward':
    value     => 1,
    permanent => 'yes',
  }
  service { 'pulse':
    ensure => running,
    enable => true,
  }

  file { '/etc/sysconfig/ha/lvs.cf':
    ensure  => present,
    content => template("${module_name}/lvs.cf.erb"),
    owner   => '0',
    group   => 'piranha',
    mode    => '0644',
    require => Package['piranha'],
    notify  => Service['pulse'],
  }

  file { '/usr/local/bin/lvscheck':
    ensure  => present,
    source  => "puppet:///modules/${module_name}/lvscheck",
    owner   => '0',
    group   => '0',
    mode    => '0755',
    require => Package['piranha'],
  }

}
