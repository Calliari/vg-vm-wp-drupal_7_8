#!/bin/bash

curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install npm -y


mkdir -p /home/vagrant/.composer

tee /home/vagrant/.composer/auth.json <<EOF
{
    "github-oauth": {
        "github.com": "git Token"
    }
}
EOF


sudo chown -R vagrant:  /home/vagrant/.composer/

mkdir -p ~/website
sudo chown -R vagrant: ~/website/


cd ~/website/
git clone https://github.com/droptica/droopler_project.git
cd droopler_project
composer install


composer drupal-scaffold
composer install



cd ~/website/droopler_project/web/themes/custom/droopler_subtheme
npm install
sudo npm install --global gulp-cli
gulp compile
