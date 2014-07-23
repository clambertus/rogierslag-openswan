define openswan::user( $username,
                      $password,
                      $ipSuffix) {
  $ip = "${openswan::ipPrefix}${ipSuffix}"

  concat::fragment { "openswan-${username}":
    target  => '/etc/ppp/chap-secrets',
    content => "${username} l2tpd ${password} ${ip}\nl2tpd ${username} ${password} ${ip}\n",
    order => 10
  }
}
