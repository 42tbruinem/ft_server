#Install the base image for Debian Buster, the OS we'll be running the container in.

FROM debian:buster

#Expose the port 80 because that's what wordpress will be loaded on.
EXPOSE 80 443
WORKDIR /root/

ARG index=on

#Install every piece of our modified LEMP stack we'll need.

RUN apt-get -y update && \
	apt-get -y upgrade && \
	apt-get -y install \
	mariadb-server \
	mariadb-client \
	unzip \
	wget \
	php \
	sudo \
	sendmail \
	php-cli \
	php-cgi \
	php7.3-zip \
	php-json \
	php-mbstring \
	php-fpm \
	php-mysql \
	nginx \
	libnss3-tools

#Configuring NGINX

#RUN		rm -rf /etc/nginx/sites-enabled/default
#COPY	/srcs/index_on.conf /etc/nginx/sites-available
#COPY	/srcs/index_off.conf /etc/nginx/sites-available
#RUN		ln -s /etc/nginx/sites-available/index_[index]/ etc/nginx/sites-enabled/server.conf

#Configuring PHPMyAdmin

RUN		mkdir -p /var/www/html/wordpress
COPY	/srcs/phpMyAdmin-4.9+snapshot-all-languages.tar.gz /tmp/
RUN		tar -zxvf /tmp/phpMyAdmin-4.9+snapshot-all-languages.tar.gz -C /tmp
RUN		cp -r /tmp/phpMyAdmin-4.9+snapshot-all-languages/. \
		/var/www/html/wordpress/phpmyadmin
RUN		chmod a+rwx,g-w,o-w /var/www/html/wordpress/phpmyadmin/tmp

#Creating the mysql database for Wordpress

RUN		service mysql start && mysql -e "CREATE DATABASE wordpress_db;" && \
		mysql -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'admin';" && \
		mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;" && \
		mysql -e "FLUSH PRIVILEGES;"

#Configuring super-user

RUN		adduser --disabled-password --gecos "" admin
RUN		sudo adduser admin sudo

#Download and install wordpress-cli

COPY	/srcs/wp-cli.phar /tmp/
RUN		chmod a+rwx,g-w,o-w /tmp/wp-cli.phar
RUN		mv /tmp/wp-cli.phar /usr/local/bin/wp
RUN		wp cli update

#Download and configure wordpress

RUN		service mysql start && sudo -u admin -i wp core download && \
		sudo -u admin -i wp core config --dbname=wordpress_db --dbuser=admin --dbpass=admin && \
		sudo -u admin -i wp core install --url=https://localhost/ --title=WordPress \
		--admin_user=admin --admin_password=admin --admin_email=thijsbruineman@gmail.com
RUN		cp -r /home/admin/. /var/www/html/wordpress
RUN		chown -R www-data:www-data /var/www/html/*

COPY	/srcs/server.key /etc/ssl/private/
COPY	/srcs/server.crt /etc/ssl/certs/
COPY	/srcs/server.conf /etc/nginx/sites-enabled
COPY	/srcs/server.conf /etc/nginx/sites-available
COPY	/srcs/config.inc.php /var/www/html/wordpress/phpmyadmin
COPY	/srcs/php.ini /etc/php/7.3/fpm/php.ini

#Start all the services when starting our image

#CMD 	service nginx start && \
#		service mysql start && \
#		mysql_secure_installation && \
#		service apache2 start && \
#		service php7.3-fpm start && \
#		echo "127.0.0.1 localhost localhost.localdomain $(hostname)" >> /etc/hosts && \
#		service sendmail start && \
#		bash
