# #!/bin/bash

# vagrant # check the vagrant CMD

# vagrant global-status # outputs status Vagrant environments for this user
# vagrant status # outputs status of the vagrant machine

# vagrant destroy -f  # destroy the VM
# vagrant up # initialize the VM
# vagrant ssh # ssh into VM

# vagrant halt # shotdown or power off the VM
# vagrant up # initialize the VM


# vagrant suspend # hibernate the VM
# vagrant resume # wake up the VM after supended

# =============================

# Ensure we have working hosts, even within protected networks.
# sudo rm /etc/resolv.conf
# echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee /etc/resolv.conf

#  Install git
# sudo apt-get install -y git

# Update the souces list and upgrade
# sudo apt-get -y update
# sudo apt-get -y upgrade

# install the install's dependecies
# sudo apt-get -f install


# sudo passwd
# echo 'root\nroot'
# exit && exit

# sudo passwd
# echo 'root\nroot'

# =============================
# change permission fo this script to be run
# chmod +x ~/script.sh





# Update the souces list and upgrade
sudo apt-get -y update
sudo apt-get -y upgrade

# install the install's dependecies
# sudo apt-get -f install -y

#  Install git
sudo apt-get install git htop -y


# ============================================================
                # Manually steps
# ============================================================
# # Install jave 8 with python
# sudo add-apt-repository ppa:openjdk-r/ppa -y
# sudo apt-get update -y
# sudo apt-get install -y openjdk-8-jdk
# sudo apt-get update -y
#
# # Install jenkins
# wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
# sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
# sudo apt-get update -y
# sudo apt-get install -y jenkins
#
# sleep 10
# # get the jenkins Administrator password
# sudo cat /var/lib/jenkins/secrets/initialAdminPassword
