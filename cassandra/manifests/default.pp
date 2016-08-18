#sudo puppet apply /vagrant/manifests/default.pp


file { 'hosts':
  path => '/etc/hosts',
  source => '/vagrant/conf/hosts'
}


yumrepo { 'datastax':
  name => 'DataStax-Apache-Cassandra',
  baseurl => 'http://rpm.datastax.com/datastax-ddc/3.7',
  enabled => 1,
  gpgcheck => 0
}

file { 'java_home.sh':
  path => '/etc/profile.d/java_home.sh',
  content => 'export JAVA_HOME=/usr',
  mode    => 755
}


package { 'jre':
  require => [ File['java_home.sh'] ],
  name   => 'java-1.8.0-openjdk',
  ensure => installed
}


package { 'datastax-ddc':
  require => [ Yumrepo['datastax'], Package['jre'] ],
  name   => 'datastax-ddc',
  ensure => installed
}


service { 'cassandra':
  require => [ Package['datastax-ddc'] ],
  provider => redhat,
  ensure => running
}
