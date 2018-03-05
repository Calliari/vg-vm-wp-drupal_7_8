#!/bin/bash

# ./create-repo-pivotal.sh --repo repoTest --pivotal pivotaltest --cms wp

# ==============================================

# Simple timer
start=$(date +'%s')

MOTD="
               _       _         _      _        _ _
 ___  ___ _ __(_)_ __ | |_    __| | ___| |_ __ _(_) |___
/ __|/ __| '__| | '_ \| __|  / _\` |/ _ \ __/ _\` | | / __|
\__ \ (__| |  | | |_) | |_  | (_| |  __/ || (_| | | \__ \\
|___/\___|_|  |_| .__/ \__|  \__,_|\___|\__\__,_|_|_|___/
                |_|

\n"



# display how to use the script
usage() {
  echo -e "\nUsage:\n\n==> $0\
  --websitename example.com\
  --cms wp\
 \n\n## This script supports and initial setup for wordpress, Drupal (7 or 8) Platforms ONLY\n"
 exit 1
}

# Define variables from options.
OPTS=`getopt -o v --long websitename:,cms: -- "$@"`
if [ $? != 0 ]; then
  usage
fi

eval set -- "$OPTS"
# set initial values of the parameters, Set defaults.
DT=$(date +%d-%m-%Y--%H:%M:%S)

while true; do
  case "$1" in
    --websitename )
      WEBSITENAME="$2"
      shift 2;;
    --cms )
      CMS="$2"
      shift 2;;
    *)
      break;;
  esac
done

# All of these parameters are required
if [ "${CMS}" = "" ] || [ "${WEBSITENAME}" = "" ]; then
  usage
fi


mkdir -p "/home/vagrant/www_website/$WEBSITENAME";

# save the working directory
CURRENT_DIRECTORY="/home/vagrant/www_website/$WEBSITENAME";


details_func() {
  echo ""
  echo "================ Jenkins job details  ==================================="
  echo "Website name installed ==> : $WEBSITENAME "
  echo "CMS platform installed ==> : $CMS "
  echo "========================================================================="
  echo ""

}

# ########################
#  DATABASE function
# #######################
database_func() {
  # crete a database
  DB_NAME=$( echo $WEBSITENAME | sed 's/-/_/g');
  DB_NAME=$( echo $DB_NAME | sed 's/\./_/g');
  mysql -uroot -ptoor -e "CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";

}
# ########################
#  END DATABASE function
# #######################

# ########################
#  NGINX function
# #######################

nginx_drupal_func(){

 sudo tee /etc/nginx/sites-available/$WEBSITENAME <<\EOL

  server {
      listen 80;

  #    server_name _;
      server_name WEBSITENAME;

      index index.php;

      root /var/www/WEBSITENAME;

      access_log /var/log/nginx/WEBSITENAME.access.log;
      error_log /var/log/nginx/WEBSITENAME.error.log error;

      # In Drupal 8, we must also match new paths where the '.php' appears in
      # the middle, such as update.php/selection. The rule we use is strict,
      # and only allows this pattern with the update.php front controller.
      # This allows legacy path aliases in the form of
      # blog/index.php/legacy-path to continue to route to Drupal nodes. If
      # you do not have any paths like that, then you might prefer to use a
      # laxer rule, such as:
      #   location ~ \.php(/|$) {
      # The laxer rule will continue to work if Drupal uses this new URL
      # pattern with front controllers other than update.php in a future
      # release.
      location ~ '\.php$|^/update.php' {

          # fastcgi_split_path_info ^(.+?\.php)(|/.*)$;
          # Security note: If you're running a version of PHP older than the
          # latest 5.3, you should have "cgi.fix_pathinfo = 0;" in php.ini
          # See http://serverfault.com/q/627903/94922 for details.
          # Block httpoxy attacks. See https://httpoxy.org/.
          fastcgi_param HTTP_PROXY "";
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          fastcgi_param PATH_INFO $fastcgi_path_info;
          fastcgi_intercept_errors on;

          # PHP 7 socket location.
          fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;

          fastcgi_keep_conn on;
          fastcgi_index  index.php;
          include        fastcgi_params;
          fastcgi_read_timeout 300;
      }

      # Block access to "hidden" files and directories whose names begin with a
      # period. This includes directories used by version control systems such
      # as Subversion or Git to store control files.
      location ~ (^|/)\. {
          return 403;
      }

 # this is for drupal
      location / {
          try_files $uri /index.php?$query_string;
      }

 # this is for wordpress
 #     location / {
 #         try_files $uri $uri/ /index.php?$query_string;
 #     }

      location @rewrite {
          rewrite ^/(.*)$ /index.php?q=$1;
      }

      # Don't allow direct access to PHP files in the vendor directory.
      location ~ /vendor/.*\.php$ {
          deny all;
          return 404;
      }

      # Fighting with Styles? This little gem is amazing.
      location ~ ^/sites/.*/files/styles/ {
          try_files $uri @rewrite;
      }

      # Handle private files through Drupal.
      location ~ ^/system/files/ { # For Drupal >= 7
          try_files $uri /index.php?$query_string;
      }

      location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
          expires max;
          log_not_found off;
      }

      location = /favicon.ico {
          log_not_found off;
          access_log off;
      }

      location = /robots.txt {
          allow all;
          log_not_found off;
          access_log off;
      }

      location ~ \..*/.*\.php$ {
          return 403;
      }

      location ~ ^/sites/.*/private/ {
          return 403;
      }

      # Allow "Well-Known URIs" as per RFC 5785
      location ~* ^/.well-known/ {
          allow all;
      }

  }

EOL

sudo ln -s /etc/nginx/sites-available/$WEBSITENAME /etc/nginx/sites-enabled/$WEBSITENAME
sudo ln -s /home/vagrant/www_website/$WEBSITENAME/public_html /var/www/$WEBSITENAME
sudo sed -i "s/WEBSITENAME/$WEBSITENAME/g" /etc/nginx/sites-available/$WEBSITENAME

}

nginx_wordpress_func(){

 sudo tee /etc/nginx/sites-available/$WEBSITENAME <<\EOL

  server {
      listen 80;

  #    server_name _;
      server_name WEBSITENAME;

      index index.php;

      root /var/www/WEBSITENAME;

      access_log /var/log/nginx/WEBSITENAME.access.log;
      error_log /var/log/nginx/WEBSITENAME.error.log error;

      # In Drupal 8, we must also match new paths where the '.php' appears in
      # the middle, such as update.php/selection. The rule we use is strict,
      # and only allows this pattern with the update.php front controller.
      # This allows legacy path aliases in the form of
      # blog/index.php/legacy-path to continue to route to Drupal nodes. If
      # you do not have any paths like that, then you might prefer to use a
      # laxer rule, such as:
      #   location ~ \.php(/|$) {
      # The laxer rule will continue to work if Drupal uses this new URL
      # pattern with front controllers other than update.php in a future
      # release.
      location ~ '\.php$|^/update.php' {

          # fastcgi_split_path_info ^(.+?\.php)(|/.*)$;
          # Security note: If you're running a version of PHP older than the
          # latest 5.3, you should have "cgi.fix_pathinfo = 0;" in php.ini
          # See http://serverfault.com/q/627903/94922 for details.
          # Block httpoxy attacks. See https://httpoxy.org/.
          fastcgi_param HTTP_PROXY "";
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          fastcgi_param PATH_INFO $fastcgi_path_info;
          fastcgi_intercept_errors on;

          # PHP 7 socket location.
          fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;

          fastcgi_keep_conn on;
          fastcgi_index  index.php;
          include        fastcgi_params;
          fastcgi_read_timeout 300;
      }

      # Block access to "hidden" files and directories whose names begin with a
      # period. This includes directories used by version control systems such
      # as Subversion or Git to store control files.
      location ~ (^|/)\. {
          return 403;
      }

 # this is for drupal
 #     location / {
 #           try_files $uri /index.php?$query_string;
 #       }

 # this is for wordpress
       location / {
          try_files $uri $uri/ /index.php?$query_string;
      }

      location @rewrite {
          rewrite ^/(.*)$ /index.php?q=$1;
      }

      # Don't allow direct access to PHP files in the vendor directory.
      location ~ /vendor/.*\.php$ {
          deny all;
          return 404;
      }

      # Fighting with Styles? This little gem is amazing.
      location ~ ^/sites/.*/files/styles/ {
          try_files $uri @rewrite;
      }

      # Handle private files through Drupal.
      location ~ ^/system/files/ { # For Drupal >= 7
          try_files $uri /index.php?$query_string;
      }

      location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
          expires max;
          log_not_found off;
      }

      location = /favicon.ico {
          log_not_found off;
          access_log off;
      }

      location = /robots.txt {
          allow all;
          log_not_found off;
          access_log off;
      }

      location ~ \..*/.*\.php$ {
          return 403;
      }

      location ~ ^/sites/.*/private/ {
          return 403;
      }

      # Allow "Well-Known URIs" as per RFC 5785
      location ~* ^/.well-known/ {
          allow all;
      }

  }

EOL

sudo ln -s /etc/nginx/sites-available/$WEBSITENAME /etc/nginx/sites-enabled/$WEBSITENAME
sudo ln -s /home/vagrant/www_website/$WEBSITENAME/public_html /var/www/$WEBSITENAME
sudo sed -i "s/WEBSITENAME/$WEBSITENAME/g" /etc/nginx/sites-available/$WEBSITENAME


}

# ########################
#  END NGINX function
# #######################

# ########################
#  DRUPAL 7 function
# #######################

gitIgnore_d7() {

  cd $CURRENT_DIRECTORY

  cat > .gitignore <<EOL

# DRUPAL 7
# Ignore configuration files that may contain sensitive information.
public_html/sites/*/settings.php
public_html/sites/default/files

public_html/sites/*/drushrc.php

# Ignore paths that contain generated content.
public_html/sites/*/files
public_html/sites/*/private

# Ignore default text files
#.htaccess
public_html/sites/all/README.txt
public_html/sites/all/modules/README.txt
public_html/sites/all/themes/README.txt
/.settings
/.buildpath
/.project
/.idea

*.DS_Store

# SASS ignores
.sass-cache
.sass-cache/*
*.css.map
create-repo-pivotal.sh

EOL

}

drupal_software_7() {

  echo '*****************************'
  echo 'Installing  drupal 7...'
  echo '*****************************'

  cd $CURRENT_DIRECTORY

  # drush dl drupal-7.54 -y
  drush dl drupal-7
  FOLDERNAME=$(ls | grep drupal)

  # drupal 7 will now be in (e.g. drupal-7.56/)
  echo 'rename and cd into public_html directory... '
  mv "$FOLDERNAME" "public_html"

  cd public_html

  echo 'downloading standard modules for druipal 7...'
  drush dl admin_menu admin_views authcache better_exposed_filters context ctools date devel diff entity entityform features field_group file_entity imce jquery_update library maillog masquerade media memcache_storage node_clone pathauto strongarm token varnish views views_bulk_operations wysiwyg -y

  drush dl varnish memcache_storage authcache -y

  DB_NAME=$( echo $WEBSITENAME | sed 's/-/_/g');
  DB_NAME=$( echo $DB_NAME | sed 's/\./_/g');
  sudo drush site-install standard -y --db-url=mysql://root:toor@localhost/"$DB_NAME" --site-name="$WEBSITENAME" --account-name=admin --account-pass=ToorAdmin7

  # sudo tee -a '$base_url = '$WEBSITENAME';  // NO trailing slash!' $WEBSITENAME/public_html/sites/default/settings.php

  # sudo chown www-data: -R $CURRENT_DIRECTORY/public_html/sites/default/files

}

# ########################
#  END DRUPAL 7 function
# #######################


# ########################
#  DRUPAL 8 function
# #######################
gitIgnore_d8() {

  cd $CURRENT_DIRECTORY

  cat > .gitignore <<EOL

# DRUPAL 8
 # This file contains default .gitignore rules. To use it, copy it to .gitignore,
# and it will cause files like your settings.php and user-uploaded files to be
# excluded from Git version control. This is a common strategy to avoid
# accidentally including private information in public repositories and patch
# files.
#
# Because .gitignore can be specific to your site, this file has a different
# name; updating Drupal core will not override your custom .gitignore file.

# Ignore core when managing all of a project's dependencies with Composer
# including Drupal core.
# public_html/core

# Core's dependencies are managed with Composer.
public_html/vendor/*
!public_html/vendor/.htaccess
!public_html/vendor/web.config


# Ignore configuration files that may contain sensitive information.
public_html/sites/*/settings*.php
public_html/sites/*/services*.yml

# Ignore paths that contain user-generated content.
public_html/sites/*/files
public_html/sites/*/private

# Ignore SimpleTest multi-site environment.
public_html/sites/simpletest

# If you prefer to store your .gitignore file in the sites/ folder, comment
# or delete the previous settings and uncomment the following ones, instead.

# Ignore configuration files that may contain sensitive information.
# */settings*.php

# Ignore paths that contain user-generated content.
# */files
# */private

# Ignore SimpleTest multi-site environment.
# simpletest

# Ignore core phpcs.xml and phpunit.xml.
public_html/core/phpcs.xml
public_html/core/phpunit.xml

/.idea
*.DS_Store

# SASS ignores
.sass-cache
.sass-cache/*
*.css.map
create-repo-pivotal.sh

EOL


}

drupal_software_8() {

  echo '*****************************'
  echo 'Installing  drupal 8...'
  echo '*****************************'

  cd $CURRENT_DIRECTORY

  drush dl drupal-8

  FOLDERNAME=$(ls | grep drupal)

  echo 'rename and cd into public_html directory... '
  mv "$FOLDERNAME" "public_html"
  cd public_html

  # composer for DRUPAL 8 only
  composer install

  echo 'downloading standard modules for druipal 8...'
  drush dl admin_toolbar captcha devel extlink field_group masquerade memcache_storage migrate_plus migrate_tools paragraphs -y

  drush dl varnish memcache_storage authcache -y

  DB_NAME=$( echo $WEBSITENAME | sed 's/-/_/g');
  DB_NAME=$( echo $DB_NAME | sed 's/\./_/g');
  sudo drush site-install standard -y --db-url=mysql://root:toor@localhost/"$DB_NAME" --site-name="$WEBSITENAME" --account-name=admin --account-pass=ToorAdmin7

  # sudo chown www-data: -R $CURRENT_DIRECTORY/public_html/sites/default/files


  # Drupal 8 sites:
  # $settings['trusted_host_patterns'] = array(
  #   '^reponame-demo\.bbdtest\.co\.uk$',
  # );
  # $settings['cache']['default'] = 'cache.backend.memcache_storage';
  # $settings['memcache']['key_prefix'] = 'reponame_demo_';
  #
  #
  # $config_directories['sync'] = '../sync';
}

# ########################
#  END DRUPAL 8 function
# #######################

# ########################
#  WORDPRESS function
# #######################
gitIgnore_wp() {

  cd $CURRENT_DIRECTORY

  cat > .gitignore <<EOL

# wordpress

*.bak
*.swp

*.idea*
*.DS_Store
public_html/wp-config.php
public_html/wp-config*

public_html/wp-content/uploads*
public_html/wp-content/cache*

*/error_log
public_html/.user.ini

public_html/wp-content/wflogs*
public_html/wp-content/themes/ofwat/twitter/cache*

node_modules

# Store provisioning configuration within local root, but separate repo for
# security.
provisioners*
create-repo-pivotal.sh

EOL

}

install_wordpress() {

echo '*****************************'
echo 'Installing  WordPress...'
echo '*****************************'

cd $CURRENT_DIRECTORY

wget -c https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
FOLDERNAME=$(ls | grep wordpress)

mv "$FOLDERNAME" "public_html"

rm latest.tar.gz

cd public_html;
sudo cp wp-config-sample.php wp-config.php
DB_NAME=$( echo $WEBSITENAME | sed 's/-/_/g');
DB_NAME=$( echo $DB_NAME | sed 's/\./_/g');
sudo sed -i "s/database_name_here/$DB_NAME/g" wp-config.php
sudo sed -i "s/username_here/root/g" wp-config.php
sudo sed -i "s/password_here/toor/g" wp-config.php



}

# ########################
#  END WORDPRESS function
# #######################
case $CMS in
  8) # starting call functions for "drupal-8"
    echo "drupal-8"
    database_func
    gitIgnore_d8
    drupal_software_8
    nginx_drupal_func
    echo -e "\n$MOTD"
    details_func
  ;;
  7) # starting call functions for "drupal-7"
    echo "drupal-7"
    database_func
    gitIgnore_d7
    drupal_software_7
    nginx_drupal_func
    echo -e "\n$MOTD"
    details_func
  ;;
  wp) # starting call functions for "wordpress"
    echo "wordpress"
    database_func
    gitIgnore_wp
    install_wordpress
    nginx_wordpress_func
    echo -e "\n$MOTD"
    details_func
  ;;
  *)
    echo -e "\nWARNING!!!\nDont know! Choose a (wp, drupal-7 or drupal-8) version to be installed!"
    usage
  ;;
esac

# remove the nginx default sinclink
if [ -f /etc/nginx/sites-enabled/default  ]; then
  sudo rm /etc/nginx/sites-enabled/default;
fi

sudo service nginx restart
# ######################## SHOULD FINISH HERE ####################


# ####################
# Final notifiation:
echo ""
echo "========================================================================="
echo "If there are errors picked up in this deployment, please"
echo "read the above notices carefully. If anything looks unusual,"
echo "contact the System Administrator or consider a rollback."

# Script complete. Give stats:
end=$(date +'%s')
diff=$(($end-$start))
echo ""
echo "Deployment completed in $diff seconds."
echo "========================================================================="
echo ""

exit 0;
