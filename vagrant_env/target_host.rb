########################################################################################################################
# GENERAL
########################################################################################################################
$TARGET_HOSTS = []
$TARGET_HOSTS_VARS = {}
$TARGET_GROUPS = {}

########################################################################################################################
# CONFIGURATION (to be modified)
########################################################################################################################
$TARGET_HOSTNAME = "openstack"
$TARGET_GROUP_NAME = "osa-target-hosts"
$TARGET_NETWORK_IPOFFSET = 10

########################################################################################################################
# PROVISIONING VARIABLES
########################################################################################################################
target_hosts = []
(1..$TARGET_NUMBER_OF_HOST).each do |i|
  target_hosts.push("#{$TARGET_HOSTNAME}#{i}")
end

target_hosts_vars = {}
(1..$TARGET_NUMBER_OF_HOST).each do |i|
  target_hosts_vars["#{$TARGET_HOSTNAME}#{i}"] = {
      "internal_ip" => "#{$NETWORK_INTERNAL_IP}#{i+$TARGET_NETWORK_IPOFFSET}",
      "hostname" => "#{$TARGET_NETWORK_IPOFFSET}#{i}"
  }
end

$TARGET_GROUPS["#{$TARGET_GROUP_NAME}"] = target_hosts
$TARGET_HOSTS_VARS = $TARGET_HOSTS_VARS.merge(target_hosts_vars)


$GROUPS = $GROUPS.merge($TARGET_GROUPS)
$HOSTS_VARS = $HOSTS_VARS.merge($TARGET_HOSTS_VARS)

########################################################################################################################
# DEFINITION
########################################################################################################################
(1..$TARGET_NUMBER_OF_HOST).each do |i|
  Vagrant.configure("2") do |config|
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.box_check_update = false

    config.vm.provider "virtualbox" do |v, override|
      override.ssh.username = $VIRTUALBOX_USERNAME
      override.vm.box = $VBOX_DEFAULT_BOXTYPE

      v.customize ["modifyvm", :id, "--cableconnected1", "on"]
    end

    config.vm.define "#{$TARGET_HOSTNAME}#{i}" do |g|
      g.vm.hostname = "#{$TARGET_HOSTNAME}#{i}"

      g.vm.provider "virtualbox" do |vb, override|
        vb.name = "cdev::osa::#{$TARGET_HOSTNAME}#{i}"
        override.vm.network "private_network", ip: "#{$NETWORK_INTERNAL_IP}#{i+$TARGET_NETWORK_IPOFFSET}"

        vb.memory = 4098
        vb.cpus = 2

      end

      if i == $TARGET_NUMBER_OF_HOST
        g.vm.provision "ansible" do |ansible|
          #ansible.verbose = "vvvv"
          ansible.limit="all"
          ansible.playbook = "prepare_target_hosts.yml"
          ansible.groups = $GROUPS
          ansible.host_vars = $HOSTS_VARS
        end
      end
    end
  end
end