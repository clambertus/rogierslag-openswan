class openswan::user( $username,
                      $password,
                      $ip) {

  concat::fragment { "openswan-${username}":
    target  => '/etc/ppp/chap-secrets',
    content => "${username} l2tpd ${password} ${ip}\nl2tpd ${username} ${password} ${ip}\n",
    order => 10
  }
}
