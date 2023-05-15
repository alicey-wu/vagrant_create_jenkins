# Defines our Vagrant environment
#
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  #create a jenkins master server
  config.vm.synced_folder ".", "/vagrant", owner: "1000", group: "1000"
   config.vm.define :jenkins do |jenkins_config|
      jenkins_config.vm.box = "centos/7"
      jenkins_config.vm.hostname = "jenkins"
      jenkins_config.vm.network :private_network, ip: "10.0.15.12"
      jenkins_config.vm.network "forwarded_port", guest: 8080, host: 9999
      jenkins_config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
      end
      jenkins_config.vm.provision :shell, path: "bootstrap-jenkins-master.sh", name: "master"
  end
  #create a jenkins slave
   config.vm.define :jenkinsslave do |jenkinsslave_config|
      jenkinsslave_config.vm.box = "centos/7"
      jenkinsslave_config.vm.hostname = "jenkins-slave"
      jenkinsslave_config.vm.network :private_network, ip: "10.0.15.13"
      jenkinsslave_config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
      end
      jenkinsslave_config.vm.provision :shell, path: "bootstrap-jenkins-slave.sh", name: "slave"
  end

   #create a jenkins slave
   config.vm.define :jenkinsslave2 do |jenkinsslave2_config|
    jenkinsslave2_config.vm.box = "centos/7"
    jenkinsslave2_config.vm.hostname = "jenkins-slave2"
    jenkinsslave2_config.vm.network :private_network, ip: "10.0.15.14"
    jenkinsslave2_config.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    jenkinsslave2_config.vm.provision :shell, path: "bootstrap-jenkins-slave.sh", name: "slave"
end

end
