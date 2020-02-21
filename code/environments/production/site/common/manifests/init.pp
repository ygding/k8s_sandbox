# common class that gets applied to all nodes
# See: "code/environments/production/hieradata/common.yaml"
# It:
#  - configures /etc/hosts entries
#  - makes sure puppet is installed and running
#  - makes sure mcollective + client is installed and running
#
class common {

  # needed for rubygem-stomp
  yumrepo { 'puppetlabs-deps':
    ensure  => 'present',
    baseurl => 'http://yum.puppetlabs.com/el/7/dependencies/$basearch',
    descr   => 'Puppet Labs Dependencies El 7 - $basearch',
    enabled => '1',
  }

  #nodes declaration
  @@host { $facts['networking']['hostname']:
    ip  => $facts['ipaddress_enp0s8'],
#    tag => ['hosttag'],
  }
## comment following line to double check.
#  Host <<||>>
  #Host <<|tag == 'hosttag'|>>

  package { 'puppet-agent':
    ensure => installed,
  }

  service { 'puppet':
    ensure  => running,
    enable  => true,
    require => Package['puppet-agent'],
  }

  if $facts['hostname'] !~ /puppet*/ {
    service { 'firewalld':
      ensure => 'stopped',
      enable => 'false',
    }
    ssh_authorized_key { 'root@puppet':
      ensure => present,
      user   => 'root',
      type   => 'ssh-rsa',
      key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDaYAtcC/7boZR/dopKIg9X7ykalqdLyR3xDY6a3gcJxxYu7CDwj2jPWsCJPeq9Nb7BT7K278EChqhLX1UQaW0naGpCpmekYEgbh9xY0uSHCMqwdSbVEfHjn4J3ZkFxugu3TNLzbjF/yb5FzMPaIJbxvUxyJ3rlBCStvbJ88Kw4hZ9aSvUD+vbxoCUaXNVPn1jUM7HlOxWdbKt7hCS8dEDgrfVKkkq3rG/MMi+wkSbXY+3h0v4ipu2BlvR8cpNJAorcy6lIrHhd/UiDPNU1wDDDsKBIb1Ig+TPXmfsD5tihLpMYka+mDzClTzEr9U7eX73Bs8r0gSCnygConzEjqAWB'
    }
    class { 'ntp':
#      servers => ['puppet'],
      servers     => ['time.asia.apple.com','pool.ntp.org','time.nist.gov'],
    }
    class {'kubernetes':
      worker => true,
    }
  }
}
