#!/bin/bash


# install ngix for drupal
echo -e "\n************\ninstall nginx\n************\n"
sudo apt install nginx -y



exit 0;

# ==================================

server {
    listen 80;

#    server_name _;
    server_name {{ website }};

    index index.php;

    root /var/www/{{ website }}/public_html;

    access_log /var/log/nginx/{{ website }}.access.log;
    error_log /var/log/nginx/{{ website }}.log error;

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

    location / {
        try_files $uri /index.php?$query_string;
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