class pe_lvs::frontend ($confighash ){

  $theip = $confighash['vip']

  exec { "ip addr add ${theip} dev eth0":
    path   => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => "ip addr list | grep ${theip}",
  }

  file_line { 'add_vip_ip_address':
    line => "ip addr add ${theip} dev eth0",
    path => '/etc/rc.local',
  }

}
