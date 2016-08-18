#sudo puppet apply /vagrant/manifests/default.pp


file { 'hosts':
  path => '/etc/hosts',
  source => '/vagrant/conf/hosts'
}


yumrepo { 'datastax':
  descr => 'DataStax Repo for Apache Cassandra',
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


file { 'cassandra.yaml':
  require => [ Package['datastax-ddc'] ],
  path => '/etc/cassandra/conf/cassandra.yaml',
  source => '/vagrant/conf/cassandra.yaml',
  owner => 'cassandra',
  group => 'cassandra',
  mode    => 755
}



service { 'cassandra':
  require => [ Package['datastax-ddc'], File['cassandra.yaml'] ],
  provider => redhat,
  ensure => running,
  enable => true
}
