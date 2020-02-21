# class to deploy master node:
# - puppetserver
# - puppetdb

class master {
  include ::firewall

  package { 'puppetserver':
    ensure  =>  'installed',
  }

  package { 'pdk':
    ensure => 'installed',
  }

  package { 'puppet-bolt':
    ensure => 'installed',
  }

  file { '/etc/systemd/system/puppetserver.service.d':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  firewall { '8140 accept - puppetserver':
    dport  => '8140',
    proto  => 'tcp',
    action => 'accept',
  }

  service { 'puppetserver.service':
    ensure  => 'running',
    enable  => 'true',
    require => Package['puppetserver'],
  }

  file { '/etc/systemd/system/puppetserver.service.d/local.conf':
    ensure  => 'file',
    content => "[Service]\nTimeoutStartSec=500",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/systemd/system/puppetserver.service.d'],
    notify  => Service['puppetserver.service'],
  }

  file { '/etc/puppetlabs/puppet/autosign.conf':
    ensure  => 'file',
    content => '*',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['puppetserver'],
    notify  => Service['puppetserver.service'],
  }

  class { '::puppetdb':
    ssl_listen_address => '0.0.0.0',
    ssl_listen_port    => '8081',
    listen_address     => '0.0.0.0',
    listen_port        => '6080',

    open_listen_port   => true,
  }
  class { '::puppetdb::master::config':
    puppetdb_server         => 'puppet',
    strict_validation       => false,
    manage_report_processor => true,
    enable_reports          => true,
    restart_puppet          => false,
  }

## NTP server configuration
  class { 'ntp':
    servers     => ['time.asia.apple.com','pool.ntp.org','time.nist.gov'],
#    udlc        => true,
  }
firewall { '123 accept - NTP':
  dport  => '123',
  proto  => 'udp',
  action => 'accept',
}

## K8s configuration
firewall { '2380 accept - ETCD API':
  dport  => '2380',
  proto  => 'tcp',
  action => 'accept',
}
firewall { '2379 accept - ETCD Listen Port':
  dport  => '2379',
  proto  => 'tcp',
  action => 'accept',
}
firewall { '4001 accept - ETCD Listen Port':
  dport  => '4001',
  proto  => 'tcp',
  action => 'accept',
}
firewall { '6443 accept - Kubeadmin':
  dport  => '6443',
  proto  => 'tcp',
  action => 'accept',
}
firewall { '6800 tcp accept - Ceph OSD Bind':
  dport  => '6800-7100',
  proto  => 'tcp',
  action => 'accept',
}
firewall { '8443 accept - Kubernetes Dashboard':
  dport  => '8443',
  proto  => 'tcp',
  action => 'accept',
}
firewall { '10250 TCP accept - Kubeadmin':
  dport  => '10250',
  proto  => 'tcp',
  action => 'accept',
}
firewall { '10250 UDP accept - Kubeadmin':
  dport  => '10250',
  proto  => 'udp',
  action => 'accept',
}
firewall {'999 accept all':
  proto   => 'all',
  action  => 'accept',
}
  class {'kubernetes':
    controller => true,
    ignore_preflight_errors => ['NumCPU'],
  }
}
