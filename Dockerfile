FROM debian:buster
COPY src/wordpress.sql ./root/
COPY src/nginx-host-conf ./root/
COPY src/wordpress.tar.gz ./root/
COPY src/config.inc.php ./root/
COPY src/start.sh ./
CMD bash start.sh && tail -f / dev / null