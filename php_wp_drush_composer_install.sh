#!/bin/bash



# =============================
#  install PHP 5.6, the same as the server bbd
# echo -e "************\ninstall php 5.6\n************"
# sudo add-apt-repository ppa:ondrej/php
# sudo apt-get update
# sudo apt-get -y install php5.6 php5.6-mcrypt php5.6-mbstring php5.6-curl php5.6-cli php5.6-mysql php5.6-gd php5.6-intl php5.6-xsl php5.6-zip



# =============================
#  install PHP 7.0, the same as the server
echo -e "\n************\ninstall php 7.0\n************\n"
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get install git unzip curl php7.0-fpm php7.0-cli php7.0-gd php7.0-mysql php7.0-xml php7.0-mbstring php7.0-mysql php7.0-intl php7.0-curl mcrypt php7.0-mcrypt -y

sudo systemctl restart php7.0-fpm

# =============================
# install composer
echo -e "\n************\ninstall composer\n************\n"
# globally
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
# curl -sS https://getcomposer.org/installer -o composer-setup.php


# =============================
# install drush
echo -e "\n************\ninstall drush\n************\n"
sudo mkdir -p /usr/local/drush
cd /usr/local/drush
sudo wget https://github.com/drush-ops/drush/releases/download/8.1.16/drush.phar
sudo chmod +x /usr/local/drush/drush.phar
sudo ln -s /usr/local/drush/drush.phar /usr/local/bin/drush

# =============================
# install wp-cli
echo -e "\n************\ninstall wp-cli\n************\n"
# http://wp-cli.org/
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
# check if the wp-cli is installed
# wp --info

# # =============================
# # install drush
# echo -e "************\ninstall drush\n************"
# sudo mkdir -p /usr/local/drush
# cd /usr/local/drush
# sudo wget http://files.drush.org/drush.phar
# sudo chmod +x /usr/local/drush/drush.phar
# sudo ln -s /usr/local/drush/drush.phar /usr/local/bin/drush
#
