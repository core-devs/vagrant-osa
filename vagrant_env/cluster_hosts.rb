########################################################################################################################
# LOADS
########################################################################################################################
require 'yaml'

$CONF = YAML.load_file('roles/cluster_hosts/vagrant/main.yml')

########################################################################################################################
# CONFIGURATION (to be modified)
########################################################################################################################
#Canary Test
conf_canary = $CONF['canary']
puts "Canary test: #{conf_canary}."

#Virtualbox Target
conf_vbox_username = $CONF['targets']['virtualbox']['vbox_username']
conf_vbox_boxtype = $CONF['targets']['virtualbox']['vbox_boxtype']
conf_vbox_iprange = $CONF['targets']['virtualbox']['vbox_iprange']

#Virtualbox Target printouts
puts
puts "conf_vbox_username::[#{conf_vbox_username}]"
puts "conf_vbox_boxtype::[#{conf_vbox_boxtype}]"
puts "conf_vbox_iprange::[#{conf_vbox_iprange}]"

#Host machines
conf_hosts = $CONF['machines']

#hosts machines printout
conf_hosts.each {|item|
  puts
  puts "hostname::[#{item['vm']['hostname']}]"
  puts "name::[#{item['vm']['name']}]"
  puts "hw.cpu::[#{item['vm']['hw']['cpus']}]"
  puts "hw.ram::[#{item['vm']['hw']['ram']}]"
}



########################################################################################################################
# PROVISIONING VARIABLES
########################################################################################################################