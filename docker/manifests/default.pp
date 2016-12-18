
file { 'hosts':
  path => '/etc/hosts',
  source => '/vagrant/conf/hosts'
}

yumrepo { "docker-repo":
  baseurl => "https://yum.dockerproject.org/repo/main/centos/7/",
  descr => "Docker Repository",
  enabled => 1,
  gpgcheck => 1,
  gpgkey =>  "https://yum.dockerproject.org/gpg"
}

package { 'docker-engine':
  require => [ Yumrepo['docker-repo'] ],
  ensure => latest
}

service { 'docker':
  require => [ Package['docker-engine'] ],
  ensure => running,
  enable => true
}

