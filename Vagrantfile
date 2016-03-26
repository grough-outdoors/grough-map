# ------------------------------
#  GROUGH MAP ENVIRONMENT
#  Luke S. Smith 2016.
#  Copyright (c) grough Limited.
#  luke.smith@grough.co.uk
# ------------------------------

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
    v.name = "map-system.vm.grough.local"
	v.memory = 2048
	v.cpus = 1
	#v.customize 'pre-boot', ['modifyhd', 'C:\Users\nlss2\VirtualBox VMs\map-system.vm.grough.local\box-disk1.vmdk', '--resize', '65536']
  end
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "map-system.vm.grough.local"
  config.vm.network :private_network, ip: "192.168.232.2"
  config.vm.provision :shell, run: "always", privileged: false, :path => "bin/linux/bootstrap.sh"
end
