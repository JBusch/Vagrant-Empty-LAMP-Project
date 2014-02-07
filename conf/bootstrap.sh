#!/usr/bin/env bash

# Exit if any following command exits with a non-zero status.
set -e

# if apache2 does no exist
if [ ! -f /etc/apache2/apache2.conf ];
then

	# Update Repository
	apt-get -y update

	# Install Database Server
	echo 'mysql-server mysql-server/root_password password vagrant' | debconf-set-selections
	echo 'mysql-server mysql-server/root_password_again password vagrant' | debconf-set-selections
	apt-get -y install mysql-client mysql-server

	# Install Apache2
	apt-get -y install apache2

	# Install PHP5 support
	apt-get -y install php5 libapache2-mod-php5 php-apc php5-mysql php5-dev php5-gd graphicsmagick

	# Install OpenSSL
	apt-get -y install openssl

	# Install PHP pear
	apt-get -y install php-pear

	# Install sendmail *optional
	# apt-get -y install sendmail

	# Install CURL dev package
	apt-get -y install libcurl4-openssl-dev

	# Install PECL HTTP (depends on php-pear, php5-dev, libcurl4-openssl-dev)
	printf "\n" | pecl install pecl_http

	# Enable PECL HTTP
	echo "extension=http.so" > /etc/php5/conf.d/http.ini

	# Enable some modules
	a2enmod deflate
	a2enmod expires
	a2enmod headers

	# Enable mod_rewrite
	a2enmod rewrite

	# Enable SSL
	a2enmod ssl

	# Add www-data to vagrant group
	usermod -a -G vagrant www-data

	# Restart services
	/etc/init.d/apache2 restart

	# Install Expect for a simulated interactive shell
	apt-get -y install expect

	# Install Git
	apt-get -y install git
	git config --global core.autocrlf input

	# Only works when you don't mount the /var/www Folder
	# remove old index.html
	# rm /var/www/index.html

	# setup new default apache site
	rm /etc/apache2/sites-enabled/000-default
	ln -s /vagrant/conf/default /etc/apache2/sites-enabled/000-default

	# setup new php.ini
	mv /etc/php5/apache2/php.ini /etc/php5/apache2/php.ini.old
	ln -s /vagrant/conf/php.ini /etc/php5/apache2/php.ini

	apache2ctl restart

fi

