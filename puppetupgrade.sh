#!/bin/sh

if [ ! -f /etc/provisioned ] ; then

  # remove strange manually placed repo file
  /bin/yum -y remove puppetlabs-release-pc1
  /bin/rm -f /etc/yum.repos.d/puppetlabs*

  # install Puppet 6.x release repo
  /bin/yum -y install http://yum.puppetlabs.com/puppet6/puppet-release-el-7.noarch.rpm
#  /bin/yum -y install ./puppet-release-el-7.noarch.rpm
  if [ $? -ne 0 ] ; then
    echo "Something went wrong installing the repository RPM"
    exit 1
  fi
  ## upgrade kerenel
  /bin/yum -y install kernel-3.10.0-1062.9.1.el7.x86_64 kernel-devel-3.10.0-1062.9.1.el7.x86_64

  # install / update puppet-agent
  /bin/yum -y install puppet-agent
  if [ $? -ne 0 ] ; then
    echo "Something went wrong installing puppet-agent"
    exit 1
  fi

  echo "10.13.37.2  puppet" >> /etc/hosts
  echo "10.13.37.101 node1" >> /etc/hosts
  echo "10.13.37.102 node2" >> /etc/hosts
  echo "10.13.37.103 node3" >> /etc/hosts
  echo "DOMAINNAME=apple.com">>/etc/sysconfig/network

  if [ `hostname` = "puppet" ]; then
    /bin/yum -y install puppetserver
    /usr/bin/systemctl enable puppetserver
    /usr/bin/systemctl start puppetserver

    # install ceph-deploy package
    /bin/yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    cat << EOM > /etc/yum.repos.d/ceph.repo
[ceph-noarch]
name=Ceph noarch packages
baseurl=https://download.ceph.com/rpm-nautilus/el7/noarch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
EOM
    yum -y install ceph-deploy python2-pip s3cmd
    #create id_rsa for ceph-deploy install, please double check and changed to puppet code

    /usr/bin/ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
  fi
  ## remove swap & create new xfs with ftype=1 for /var/lib/docker
  /usr/sbin/swapoff -a
  /usr/bin/sed -i "/swap/c \/dev\/mapper\/centos-swap\    /var\/lib\/docker xfs  defaults 0 0" /etc/fstab
  /usr/sbin/mkfs.xfs -f -n ftype=1 /dev/centos/swap
  /usr/bin/mkdir -p /var/lib/docker
  /usr/bin/mount -a
  ## finish provision
  touch /etc/provisioned
fi
