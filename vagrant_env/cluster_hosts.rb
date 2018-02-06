########################################################################################################################
# LOADS
########################################################################################################################
require 'yaml'

$CONF = YAML.load_file('roles/cluster_hosts/vagrant/main.yml')

########################################################################################################################
# CONFIGURATION & TESTS
########################################################################################################################
#Canary Test
conf_canary = $CONF['canary']
puts "Canary test: #{conf_canary}."
puts

#Virtualbox Target
conf_vbox_username = $CONF['targets']['virtualbox']['vbox_username']
conf_vbox_boxtype = $CONF['targets']['virtualbox']['vbox_boxtype']
conf_vbox_iprange = $CONF['targets']['virtualbox']['vbox_iprange']
conf_vbox_ipoffset = $CONF['targets']['virtualbox']['vbox_ipoffset']

#Virtualbox Target printouts
puts "conf_vbox_username::[#{conf_vbox_username}]"
puts "conf_vbox_boxtype::[#{conf_vbox_boxtype}]"
puts "conf_vbox_iprange::[#{conf_vbox_iprange}]"
puts

#Host machines
conf_hosts = $CONF['machines']

#hosts machines printout
conf_hosts.each_with_index {|item, index|
  puts "#{index}:hostname::[#{item['vm']['hostname']}]"
  puts "#{index}:name::[#{item['vm']['name']}]"
  puts "#{index}:hw.cpu::[#{item['vm']['hw']['cpus']}]"
  puts "#{index}:hw.ram::[#{item['vm']['hw']['ram']}]"
  puts
}

########################################################################################################################
# PROVISIONING & VAGRANT MAGIC
########################################################################################################################
conf_hosts.each_with_index do |item, index|
  Vagrant.configure("2") do |config|

    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.box_check_update = false

    config.vm.provider "virtualbox" do |v, override|
      override.ssh.username = conf_vbox_username
      override.vm.box = conf_vbox_boxtype

      v.customize ["modifyvm", :id, "--cableconnected1", "on"]
    end

    config.vm.define "#{item['vm']['hostname']}" do |g|
      g.vm.hostname = "#{item['vm']['hostname']}"

      g.vm.provider "virtualbox" do |vb, override|
        vb.name = "#{item['vm']['name']}"
        override.vm.network "private_network", ip: "#{conf_vbox_iprange}.#{index+conf_vbox_ipoffset}"

        vb.memory = "#{item['vm']['hw']['ram']}"
        vb.cpus = "#{item['vm']['hw']['cpus']}"
      end
    end
  end
end

