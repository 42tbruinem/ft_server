#Install the base image for Debian Buster, the OS we'll be running the container in.

FROM debian:buster
#CMD bash

#Install every piece of our modified LEMP stack we'll need.

RUN apt-get -y update && \
	apt-get -y upgrade && \
	apt-get -y install \
	mariadb-server \
	wget \
	php \
	php-cli \
	php-cgi \
	php-mbstring \
	php-fpm \
	php-mysql \
	nginx \
	libnss3-tools

#Expose the port 80 because that's what wordpress will be loaded on.

EXPOSE 80
WORKDIR /root/

#Configure NGINX

RUN service nginx restart
