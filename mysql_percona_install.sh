#!/bin/bash


# https://www.percona.com/doc/percona-server/LATEST/installation/apt_repo.html

export DEBIAN_FRONTEND=noninteractive

# download the percona mysql engine
wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb


# Install the downloaded package with dpkg. To do that, run the following commands as root or with sudo:
sudo dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb


#  # check the repository setup in the
# /etc/apt/sources.list.d/percona-release.list


# update the packages
sudo apt-get update -y

# setting up the password "mypassword"
echo "percona-server-server-5.7 percona-server-server-5.7/re-root-pass password toor" | sudo debconf-set-selections
echo "percona-server-server-5.7 percona-server-server-5.7/root-pass password toor" | sudo debconf-set-selections

echo -e "\n************\ninstall percona MySQL\n************\n";
sudo apt-get -y install percona-server-server-5.7

#
##
###
####
#####
######
# install the server package:

# echo -e "\n************\ninstall percona MySQL\n************\n"
# sudo apt-get -y install percona-server-server-5.7 >/dev/null 2>&1 &
#
# COUNTER=0;
# MYSQL="";
# while [ "${MYSQL}" = "" ]; do
#     # MYSQL=$(ps aux | grep mysql);
#
#     if [ ! -d /var/lib/mysql/mysql ]; then
#       echo -e "Mysql still installing...$COUNTER seconds\n"
#       let COUNTER=COUNTER+1
#       sleep 1
#     fi
#
#     # MYSQL=$(ps aux | grep mysql);
#     MYSQL=$(sudo ls /var/lib/mysql/mysql);
# done

echo -e "\nFinished\n******************\nMysql Installed! \n******************\n";
#######
#####
####
###
##
#


echo -e "\n************\nRestart MySQL\n************\n"
sudo service mysql restart

#==============================

# crete a database
# mysql -uroot -ptoor -e "CREATE DATABASE test_project_database CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";



# check how thw percone or mysql=-server set the password
# sudo cat /var/cache/debconf/passwords.dat



# Name: mysql-server/root_password
# Template: mysql-server/root_password
# Value: toor
# Owners: percona-server-server-5.7
# Flags: seen
#
# Name: mysql-server/root_password_again
# Template: mysql-server/root_password_again
# Value: toor
# Owners: percona-server-server-5.7
# Flags: seen
#
# Name: percona-server-server-5.7/re-root-pass
# Template: percona-server-server-5.7/re-root-pass
# Owners: percona-server-server-5.7
# Flags: seen
#
# Name: percona-server-server-5.7/root-pass
# Template: percona-server-server-5.7/root-pass
# Value:
# Owners: percona-server-server-5.7
# Flags: seen
