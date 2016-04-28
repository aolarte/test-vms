class base::common {
  file { "hosts":
    path => "/etc/hosts",
    source => '/vagrant/conf/hosts'
  }
  
  yumrepo { "cloudera-repo":
    require => [ File['hosts'] ],
    baseurl => "https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/5/",
    descr => "Cloudera's Distribution for Hadoop, Version 5",
    enabled => 1,
    gpgcheck => 1,
    gpgkey =>  "https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera"
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
}



node /^master\d+$/ {
  include base::common
  
  package { 'hadoop-hdfs-namenode':
    require => [ Yumrepo['cloudera-repo'] ],
    name   => 'hadoop-hdfs-namenode',
    ensure => installed
  }
  
  
  package { 'hadoop-yarn-resourcemanager':
    require => [ Yumrepo['cloudera-repo'] ],
    name   => 'hadoop-yarn-resourcemanager',
    ensure => installed
  }
  
  file { 'core-site.xml':
    require => [ Package['hadoop-hdfs-namenode'] , Package['hadoop-yarn-resourcemanager'] ],
    path => '/etc/hadoop/conf/core-site.xml',
    source => '/vagrant/conf/core-site.xml',
    notify  => [ Service['hadoop-hdfs-namenode'] , Service['hadoop-yarn-resourcemanager'] ],
  }
  
  exec {'hdfs-format':
    require => [ Package['jre'], Package['hadoop-hdfs-namenode'] ],
    command => '/usr/bin/hdfs namenode -format',
    creates => '/var/lib/hadoop-hdfs/cache/hdfs',
    user => 'hdfs'
  }
  
  service { 'hadoop-hdfs-namenode':
    require => [ Package['jre'], Package['hadoop-hdfs-namenode'], Exec['hdfs-format'] ],
    ensure => running,
  }
  
  
  
  service { 'hadoop-yarn-resourcemanager':
    require => [ Package['jre'], Package['hadoop-yarn-resourcemanager'], Service['hadoop-hdfs-namenode'] ],
    ensure => running,
  }
  
  
}

node /^slave\d+$/ {
  include base::common
  
  package { 'hadoop-yarn-nodemanager':
    require => [ Yumrepo['cloudera-repo'] ],
    name   => 'hadoop-yarn-nodemanager',
    ensure => installed
  }
  
  package { 'hadoop-hdfs-datanode':
    require => [ Yumrepo['cloudera-repo'] ],
    name   => 'hadoop-hdfs-datanode',
    ensure => installed
  }
  
  package { 'hadoop-mapreduce':
    require => [ Yumrepo['cloudera-repo'] ],
    name   => 'hadoop-mapreduce',
    ensure => installed
  }
  
  file { 'core-site.xml':
    require => [ Package['hadoop-yarn-nodemanager'] , Package['hadoop-hdfs-datanode'] , Package['hadoop-mapreduce']],
    path => '/etc/hadoop/conf/core-site.xml',
    source => '/vagrant/conf/core-site.xml',
    notify  => [ Service['hadoop-hdfs-datanode'] ],
  }
  
  file { 'yarn-site.xml':
    require => [ Package['hadoop-yarn-nodemanager'] , Package['hadoop-hdfs-datanode'] , Package['hadoop-mapreduce']],
    path => '/etc/hadoop/conf/yarn-site.xml',
    source => '/vagrant/conf/yarn-site.xml',
    notify  => [ Service['hadoop-yarn-nodemanager'] ],
  }
  
  service { 'hadoop-hdfs-datanode':
    require => [ Package['jre'], Package['hadoop-hdfs-datanode'] ],
    ensure => running,
  }
  
  service { 'hadoop-yarn-nodemanager':
    require => [ Package['jre'], Package['hadoop-yarn-nodemanager'] ],
    ensure => running,
  }
}
