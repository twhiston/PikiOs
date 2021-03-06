#!/usr/bin/env bash

if [ "$FULLPAGEOS_INCLUDE_LIGHTTPD" == "yes" ]
then
    # Add the repos necessary to install php 7.0
    cat <<EOT >> /etc/apt/sources.list
deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi
EOT

    cat <<EOT >> /etc/apt/preferences
Package: *
Pin: release n=jessie
Pin-Priority: 600
EOT

    apt-get update

    DEBIAN_FRONTEND=noninteractive apt-get install -y -t stretch lighttpd php7.0-common php7.0-cgi php7.0 php7.0-opcache php7.0-curl php7.0-common php7.0-cli php7.0-xml php7.0-mbstring
    lighty-enable-mod fastcgi-php
    #service lighttpd force-reload
    chown -R www-data:www-data /var/www/html
    chmod 775 /var/www/html
    usermod -a -G www-data pi
    systemctl enable clear_lighttpd_cache.service
    systemctl enable ssh.socket

    pushd /var/www/html
        #Put git clones in place
        if [ "${FULLPAGEOS_INCLUDE_DASHBOARD}" == "yes" ]
        then
            gitclone FULLPAGEOS_DASHBOARD_REPO FullPageDashboard
            chown -R pi:pi FullPageDashboard
            chown -R www-data:www-data FullPageDashboard
            chmod 775 FullPageDashboard
            pushd /var/www/html/FullPageDashboard
                  php -r "readfile('https://getcomposer.org/installer');" | php
                  # Install App dependencies using Composer
                  ./composer.phar install --no-interaction --no-ansi --optimize-autoloader
            popd
        fi
    popd

    echo "enabled" > /boot/check_for_httpd
else
    echo "disabled" > /boot/check_for_httpd
fi
