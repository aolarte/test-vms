include packagecloud

file { 'hosts':
  path => '/etc/hosts',
  source => '/vagrant/conf/hosts'
}

packagecloud::repo { 'rabbitmq/rabbitmq-server':
  type => 'rpm',  # or "deb" or "gem"
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
  source => '/vagrant/conf/enabled_plugins'
}

file { 'rabbitmq-plugins':
  require => [ Package['rabbitmq-server'] ],
  path => '/etc/rabbitmq/rabbitmq.config',
  source => '/vagrant/conf/rabbitmq.config'
}

service { 'rabbitmq-server':
  require => [ Package['rabbitmq-server'], File['rabbitmq-conf'], File['rabbitmq-plugins'] ],
  ensure => running,
}


/*
yumrepo { "cloudera-repo":
  baseurl => "https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/5/",
  descr => "Cloudera's Distribution for Hadoop, Version 5",
  enabled => 1,
  gpgcheck => 1,
  gpgkey =>  "https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera"
}


yumrepo { "cloudera-kafka-repo":
  require => [ Yumrepo["cloudera-repo"] ],
  baseurl => "http://archive.cloudera.com/kafka/redhat/6/x86_64/kafka/2.0.1",
  descr => "Cloudera's Distribution for Kafka",
  enabled => 1,
  gpgcheck => 1,
  gpgkey =>  "http://archive.cloudera.com/kafka/redhat/6/x86_64/kafka/RPM-GPG-KEY-cloudera"
}



package { 'jre':
  require => [ File["java_home.sh"] ],
  name   => 'java-1.8.0-openjdk',
  ensure => installed
}

file { "java_home.sh":
  path => "/etc/profile.d/java_home.sh",
  content => "export JAVA_HOME=/usr",
  mode    => 755
}

package { 'zookeeper-server':
  require => [ Yumrepo["cloudera-repo"], Package["jre"] ],
  name   => 'zookeeper-server',
  ensure => installed
}

package { 'kafka-server':
  require => [ Yumrepo["cloudera-kafka-repo"], Package["zookeeper-server"] ],
  name   => 'kafka-server',
  ensure => installed
}

exec { "zookeeper-init":
  require => [ Package['zookeeper-server'] ],
  command => "/usr/bin/zookeeper-server-initialize",
  user => "zookeeper",
  creates => "/var/lib/zookeeper/version-2"
}

service { 'zookeeper-server':
  require => [ Package['zookeeper-server'], Exec['zookeeper-init'] ],
  ensure => running,
}

file { 'kafka-conf':
  path => "/etc/kafka/conf/server.properties",
  source => '/vagrant/conf/server.properties'
}


service { 'kafka-server':
  require => [ Package['kafka-server'], Service['zookeeper-server'], File['kafka-conf'] ],
  ensure => running,
}

*/