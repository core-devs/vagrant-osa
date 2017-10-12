########################################################################################################################
# GENERAL
########################################################################################################################
$DEPLOYER_HOSTS = []
$DEPLOYER_HOSTS_VARS = {}
$DEPLOYER_GROUPS = {}

########################################################################################################################
# CONFIGURATION (to be modified)
########################################################################################################################
$DEPLOYER_HOSTNAME = "deployer"
$DEPLOYER_GROUP_NAME = "osa-deployment-host"
$DEPLOYER_NETWORK_IPOFFSET = 9

########################################################################################################################
# PROVISIONING VARIABLES
########################################################################################################################
deployer_hosts = []
(1..$DEPLOYMENT_NUMBER_OF_HOST).each do |i|
  deployer_hosts.push("#{$DEPLOYER_HOSTNAME}#{i}")
end

deployer_hosts_vars = {}
(1..$DEPLOYMENT_NUMBER_OF_HOST).each do |i|
  deployer_hosts_vars["#{$DEPLOYER_HOSTNAME}#{i}"] = {
      "internal_ip" => "#{$NETWORK_INTERNAL_IP}#{i+$DEPLOYER_NETWORK_IPOFFSET}",
      "hostname" => "#{$DEPLOYER_NETWORK_IPOFFSET}#{i}"
  }
end

$DEPLOYER_GROUPS["#{$DEPLOYER_GROUP_NAME}"] = deployer_hosts
$DEPLOYER_GROUPS["#{$DEPLOYER_GROUP_NAME}:vars"] = deployer_hosts_vars

$GROUPS = $GROUPS.merge($DEPLOYER_GROUPS)
$HOSTS_VARS = $HOSTS_VARS.merge($DEPLOYER_HOSTS_VARS)

########################################################################################################################
# DEFINITION
########################################################################################################################
(1..$DEPLOYMENT_NUMBER_OF_HOST).each do |i|
  Vagrant.configure("2") do |config|
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.box_check_update = false

    config.vm.provider "virtualbox" do |v, override|
      override.ssh.username = $VIRTUALBOX_USERNAME
      override.vm.box = $VBOX_DEFAULT_BOXTYPE

      v.customize ["modifyvm", :id, "--cableconnected1", "on"]
    end

    config.vm.define "#{$DEPLOYER_HOSTNAME}#{i}" do |g|
      g.vm.hostname = "#{$DEPLOYER_HOSTNAME}#{i}"

      g.vm.provider "virtualbox" do |vb, override|
        vb.name = "cdev::osa::#{$DEPLOYER_HOSTNAME}#{i}"
        override.vm.network "private_network", ip: "#{$NETWORK_INTERNAL_IP}#{i+$DEPLOYER_NETWORK_IPOFFSET}"

        vb.memory = 2048
        vb.cpus = 2

      end

      if i == $DEPLOYMENT_NUMBER_OF_HOST
        g.vm.provision "ansible" do |ansible|
          #ansible.verbose = "vvvv"
          ansible.limit="all"
          ansible.playbook = "prepare_deployment_host.yml"
          ansible.groups = $GROUPS
          ansible.host_vars = $HOSTS_VARS
        end
      end
    end
  end
end