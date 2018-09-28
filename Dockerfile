FROM ubuntu

ENV fpm_conf /etc/php/7.2/fpm/pool.d/www.conf
ENV php_ini /etc/php/7.2/fpm/php.ini

RUN apt-get update && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get -y install nginx vim php7.2-fpm php7.2 php-pear curl openssl supervisor php-pear php7.2-dev libmcrypt-dev \
	php7.2-xsl php-xdebug php-apcu php7.2-intl php-imagick php7.2-gmp \
	php7.2-xml php7.2-zip php7.2-bz2 php7.2-mbstring php7.2-gd php7.2-ldap && \
    pecl install channel://pecl.php.net/mcrypt-1.0.1 && \
	openssl req \
	    -x509 \
	    -newkey rsa:2048 \
	    -keyout /etc/ssl/private/ssl-cert-snakeoil.key \
	    -out /etc/ssl/certs/ssl-cert-snakeoil.pem \
	    -days 1024 \
	    -nodes \
	    -subj /CN=localhost && \
    apt-get -y remove php7.2-dev && \
	apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_* && \
    rm -rf /etc/nginx/nginx.conf && \
    rm -rf /etc/nginx/sites-enabled/default && \
    rm -rf /etc/nginx/sites-available/default && \
    sed -i \
        -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
        -e "s/pm.max_children = 5/pm.max_children = 10/g" \
        -e "s/pm.start_servers = 2/pm.start_servers = 3/g" \
        -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
        -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" \
        -e "s/;pm.max_requests = 500/pm.max_requests = 200/g" \
        -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
        -e "s/^;clear_env = no$/clear_env = no/" \
        ${fpm_conf} && \
  	sed -i \
    	-e "s/;session.save_path = \"\/var\/lib\/php\/sessions\"/session.save_path = \"\/var\/lib\/php\/sessions\"/g" \
    	${php_ini} && \
    mkdir /var/run/php && \
    echo "extension=mcrypt.so" >> /etc/php/7.2/fpm/conf.d/mcrypt.ini

COPY conf/supervisor/nginx-php-fpm.conf /etc/supervisor/conf.d/supervisord.conf
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/site/ /etc/nginx/sites-available/
COPY script/start.sh /usr/local/bin/start.sh


RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf && \
	ln -s /etc/nginx/sites-available/default-ssl.conf /etc/nginx/sites-enabled/default-ssl.conf && \
	chmod 755 /usr/local/bin/start.sh

EXPOSE 443 80

CMD ["/usr/local/bin/start.sh"]
