require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

def use_puppet4?
  (ENV['PUPPET_INSTALL_VERSION'] =~ %r{^2016}) ? true : false
end

def use_puppet5?
  (ENV['PUPPET_INSTALL_VERSION'] =~ %r{(^2017|^2018)}) ? true : false
end

def build_url(platform)
  if use_puppet4?
    url4 = 'http://%{mngr}.puppetlabs.com/puppetlabs-release-pc1%{plat}'
    case platform
    when 'el' then url4 % { mngr: 'yum', plat: '-el-' }
    when 'fedora' then url4 % { mngr: 'yum', plat: '-fedora-' }
    when 'debian', 'ubuntu' then url4 % { mngr: 'apt', plat: '-' }
    else
      raise "build_url() called with unsupported platform '#{platform}'"
    end
  elsif use_puppet5?
    url5 = 'http://%{mngr}.puppetlabs.com/%{dir}puppet5-release%{plat}'
    case platform
    when 'el' then url5 % { mngr: 'yum', dir: 'puppet5/', plat: '-el-' }
    when 'fedora' then url5 % { mngr: 'yum', dir: 'puppet5/', plat: '-fedora-' }
    when 'debian', 'ubuntu' then url5 % { mngr: 'apt', dir: '', plat: '-' }
    else
      raise "build_url() called with unsupported platform '#{platform}'"
    end
  else
    url6 = 'http://%{mngr}.puppetlabs.com/%{dir}puppet6-release%{plat}'
    case platform
    when 'el' then url6 % { mngr: 'yum', dir: 'puppet6/', plat: '-el-' }
    when 'fedora' then url6 % { mngr: 'yum', dir: 'puppet6/', plat: '-fedora-' }
    when 'debian', 'ubuntu' then url6 % { mngr: 'apt', dir: '', plat: '-' }
    else
      raise "build_url() called with unsupported platform '#{platform}'"
    end
  end
end

hosts.each do |host|
  if host['platform'] =~ %r{debian}
    on host, 'echo \'export PATH=/var/lib/gems/1.8/bin/:${PATH}\' >> ~/.bashrc'
  end
  # install_puppet
  if host['platform'] =~ %r{el-(5|6|7)}
    relver = Regexp.last_match(1)
    on host, "rpm -ivh #{build_url('el')}#{relver}.noarch.rpm"
    on host, 'yum install -y puppetserver'
  elsif host['platform'] =~ %r{fedora-(\d+)}
    relver = Regexp.last_match(1)
    on host, "rpm -ivh #{build_url('fedora')}#{relver}.noarch.rpm"
    on host, 'yum install -y puppetserver'
  elsif host['platform'] =~ %r{(ubuntu|debian)}
    unless host.check_for_package 'curl'
      on host, 'apt-get install -y curl'
    end
    # For openjdk8
    if host['platform'].version == '8' && !use_puppet4?
      create_remote_file(host,
                         '/etc/apt/sources.list.d/jessie-backports.list',
                         'deb https://artifactory.delivery.puppetlabs.net/artifactory/debian_archive__remote/ jessie-backports main')
      on host, 'apt-get -y -m update'
      install_package(host, 'openjdk-8-jre-headless')
    end
    on host, 'apt-get install apt-transport-https --assume-yes'
    on host, "curl -O #{build_url('debian')}$(lsb_release -c -s).deb"
    if use_puppet4?
      on host, 'dpkg -i puppetlabs-release-pc1-$(lsb_release -c -s).deb'
    elsif use_puppet5?
      on host, 'dpkg -i puppet5-release-$(lsb_release -c -s).deb'
    else
      on host, 'dpkg -i puppet6-release-$(lsb_release -c -s).deb'
    end
    on host, 'apt-get -y -m update'
    on host, 'apt-get install -y puppetserver'
  else
    raise "install_puppet() called for unsupported platform '#{host['platform']}' on '#{host.name}'"
  end
end

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'
install_ca_certs unless ENV['PUPPET_INSTALL_TYPE'] =~ %r{pe}i
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  hosts.each do |host|
    if host[:platform] =~ %r{el-7-x86_64} && host[:hypervisor] =~ %r{docker}
      on(host, "sed -i '/nodocs/d' /etc/yum.conf")
    end
  end
end
