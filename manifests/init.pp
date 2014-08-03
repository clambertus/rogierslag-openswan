# == Class: openswan
#
# Full description of class openswan here.
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
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { openswan:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class openswan( $ip,
                $gateway,
                $secret,
                $range = 112,
                $block = 2) {

  include firewall

  if $block == 1 {
    $vpnIp      = "10.${range}.${range}.1"
    $startBlock = "10.${range}.${range}.10"
    $endBlock   = "10.${range}.${range}.250"
    $ipPrefix = "10.${range}.${range}."
  } elsif $block == 2 {
    $vpnIp      = "192.168.${range}.1"
    $startBlock = "192.168.${range}.10"
    $endBlock   = "192.168.${range}.250"
    $ipPrefix = "192.168.${range}."
  } else {
    die ( "Only blocks 1 and 2 are allowed" )
  }
  $ipSubnet = "${vpnIp}/24"

  sysctl { 'net.ipv4.ip_forward': value => '1' }

  package { 'openswan':
    ensure => present
  }

  package { 'ppp':
    ensure => present
  }

  package { 'xl2tpd':
    ensure => present
  }

  file { '/etc/ipsec.conf':
    ensure  => present,
    owner   => 'root',
    content => template('openswan/ipsec.conf.erb'),
    require => Package['openswan'],
    notify  => [Service['ipsec'],Service['xl2tpd']]
  }

  file { '/etc/ipsec.d/l2tp-psk.conf':
    ensure  => present,
    owner   => 'root',
    content => template('openswan/l2tp-psk.conf.erb'),
    require => Package['openswan'],
    notify  => [Service['ipsec'],Service['xl2tpd']]
  }

  file { '/etc/xl2tpd/xl2tpd.conf':
    ensure  => present,
    owner   => 'root',
    content => template('openswan/xl2tpd.conf.erb'),
    require => Package['xl2tpd'],
    notify  => [Service['ipsec'],Service['xl2tpd']]
  }

  file { '/etc/ppp/options.xl2tpd':
    ensure  => present,
    source  => 'puppet:///modules/openswan/options.xl2tpd',
    require => Package['xl2tpd'],
    notify  => [Service['ipsec'],Service['xl2tpd']]
  }

  file { '/etc/ppp':
    ensure => directory
  }

  concat { '/etc/ppp/chap-secrets':
    ensure  => present,
    owner   => 'root',
    mode    => '0700',
    require => File['/etc/ppp/'],
    notify  => [Service['ipsec'],Service['xl2tpd']]
  }

  concat::fragment { 'chap-secretsDefault':,
    target  => '/etc/ppp/chap-secrets',
    content => "# Secrets for authentication using CHAP\n# client	server	secret			IP addresses\n\n",
    order   => 01
  }

  firewall { '300 VPN Server routing':
    proto   => 'all',
    chain  => 'FORWARD',
    destination => $ipSubnet,
    iniface => 'eth0',
    action  => 'accept',
  }
  
  firewall { '301 VPN Server routing':
    proto  => 'all',
    chain  => 'FORWARD',
    source => $ipSubnet,
    action => 'accept',
  }
  
  firewall { '302 VPN Server routing':
    proto       => 'all',
    chain       => 'FORWARD',
    destination => $ipSubnet,
    action      => 'drop',
  }
  
  firewall { '303 VPN Server routing':
    chain    => 'POSTROUTING',
    jump     => 'MASQUERADE',
    proto    => 'all',
    outiface => 'eth0',
    source   => $ipSubnet,
    table    => 'nat',
  }

  firewall { '304 VPN Server':
    proto => 'tcp',
    port  => [500,4500,1701],
    action => 'accept'
  }

  firewall { '305 VPN Server':
    proto => 'udp',
    port  => [500,4500,1701],
    action => 'accept'
  }

  file { '/etc/ipsec.secrets':
    ensure  => present,
    content => template('openswan/ipsec.secrets.erb'),
    owner   => 'root',
    mode    => '0700',
    require => Package['openswan'],
    notify  => [Service['ipsec'],Service['xl2tpd']]
  }

  service { 'pppd-dns':
    ensure => running,
    notify => [Service['ipsec'],Service['xl2tpd']]
  }

  service { 'xl2tpd':
    ensure => running
  }

  service { 'ipsec':
    ensure => running
  } 
}
