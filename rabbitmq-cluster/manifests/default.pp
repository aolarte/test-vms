
file { 'hosts':
  path => '/etc/hosts',
  source => '/vagrant/conf/hosts'
}

yumrepo { 'datastax':
  name => 'DataStax Repo for Apache Cassandra',
  baseurl = 'http://rpm.datastax.com/community'
  enabled = true,
  gpgcheck = false
}

package { 'epel-release':
  ensure => latest
}

package { 'erlang':
  require => [ Package['epel-release'] ],
  ensure => latest
}


package { 'rabbitmq-server':
  require => [ Packagecloud::Repo['rabbitmq/rabbitmq-server'], Package['erlang'] ],
  name   => 'rabbitmq-server',
  ensure => installed
}



file { 'rabbitmq-conf':
  require => [ Package['rabbitmq-server'] ],
  path => '/etc/rabbitmq/enabled_plugins',
  source => '/vagrant/conf/enabled_plugins',
  notify => Service['rabbitmq-server']
}

file { 'rabbitmq-plugins':
  require => [ Package['rabbitmq-server'] ],
  path => '/etc/rabbitmq/rabbitmq.config',
  source => '/vagrant/conf/rabbitmq.config',
  notify => Service['rabbitmq-server']
}

file { 'erlang-cookie':
  require => [ Package['rabbitmq-server'] ],
  path => '/var/lib/rabbitmq/.erlang.cookie',
  source => '/vagrant/conf/erlang.cookie',
  owner => 'rabbitmq',
  group => 'rabbitmq',
  notify => Service['rabbitmq-server']
}

service { 'rabbitmq-server':
  require => [ Package['rabbitmq-server'], File['rabbitmq-conf'], File['rabbitmq-plugins'] ],
  ensure => running,
}

