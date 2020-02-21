#require './vagrant-provision-reboot-plugin'

Vagrant.configure(2) do |config|

#  config.vbguest.auto_update = false

  config.vm.define "puppet", primary: true do |puppet|
    puppet.vm.hostname = "puppet"
    puppet.vm.box = "puppetlabs/centos-7.2-64-puppet"
    puppet.vm.box_version = "1.0.1"
    puppet.vm.network "private_network", ip: "10.13.37.2"
#    puppet.vm.network :forwarded_port, guest: 8080, host: 8080, id: "puppetdb"
    puppet.vm.synced_folder "code", "/etc/puppetlabs/code"
    puppet.vm.provider :virtualbox do |vb|
      vb.name = "ceph_puppet"
      vb.cpus = "4"
      vb.memory = "5120"
    end
    puppet.vm.provision "shell", path: "puppetupgrade.sh"
    puppet.vm.provision "puppet" do |puppetapply|
      puppetapply.environment = "production"
      puppetapply.environment_path = ["vm", "/etc/puppetlabs/code/environments"]
    end
#    puppet.vm.provision :unix_reboot
  end

# client nodes
    config.vm.define "node1", primary: true do |node1|
      node1.vm.hostname = "node1"
      node1.vm.box = "puppetlabs/centos-7.2-64-puppet"
      node1.vm.box_version = "1.0.1"
      node1.vm.network "private_network", ip: "10.13.37.101"
      node1.vm.provision "shell", path: "puppetupgrade.sh"
#      node1.vm.provision :unix_reboot
      node1.vm.provision "shell", inline: "/bin/systemctl start puppet.service"
      node1.vm.provider :virtualbox do |vb|
        line = `VBoxManage list systemproperties | grep "Default machine folder"`
        vb_machine_folder = line.split(':')[1].strip()
        vb.name = "ceph_node1"
        vb.memory = "1536"
        osd_disk = File.join(vb_machine_folder, vb.name, 'osd.vdi')
        unless File.exist?(osd_disk)
          vb.customize ['createhd', '--filename', osd_disk, '--format', 'VDI', '--size', 50 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 0, '--device', 1, '--type', 'hdd', '--medium', osd_disk]
      end
    end

    config.vm.define "node2", primary: true do |node2|
      node2.vm.hostname = "node2"
      node2.vm.box = "puppetlabs/centos-7.2-64-puppet"
      node2.vm.box_version = "1.0.1"
      node2.vm.network "private_network", ip: "10.13.37.102"
      node2.vm.provision "shell", path: "puppetupgrade.sh"
      node2.vm.provision "shell", inline: "/bin/systemctl start puppet.service"
  #    node2.vm.provision :unix_reboot
      node2.vm.provider :virtualbox do |vb|
        line = `VBoxManage list systemproperties | grep "Default machine folder"`
        vb_machine_folder = line.split(':')[1].strip()
        vb.name = "ceph_node2"
        vb.memory = "1536"
        osd_disk = File.join(vb_machine_folder, vb.name, 'osd.vdi')
        unless File.exist?(osd_disk)
          vb.customize ['createhd', '--filename', osd_disk, '--format', 'VDI', '--size', 50 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 0, '--device', 1, '--type', 'hdd', '--medium', osd_disk]
      end
    end

    config.vm.define "node3", primary: true do |node3|
      node3.vm.hostname = "node3"
      node3.vm.box = "puppetlabs/centos-7.2-64-puppet"
      node3.vm.box_version = "1.0.1"
      node3.vm.network "private_network", ip: "10.13.37.103"
      node3.vm.provision "shell", path: "puppetupgrade.sh"
      node3.vm.provision "shell", inline: "/bin/systemctl start puppet.service"
#      node3.vm.provision :unix_reboot
      node3.vm.provider :virtualbox do |vb|
        line = `VBoxManage list systemproperties | grep "Default machine folder"`
        vb_machine_folder = line.split(':')[1].strip()
#       vb.name = node3.vm.hostname
        vb.name = "ceph_node3"
        osd_disk = File.join(vb_machine_folder, vb.name, 'osd.vdi')
        vb.memory = "1536"
        unless File.exist?(osd_disk)
          vb.customize ['createhd', '--filename', osd_disk, '--format', 'VDI', '--size', 50 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 0, '--device', 1, '--type', 'hdd', '--medium', osd_disk]
      end
    end
end
