FROM ubuntu

ENV fpm_conf /etc/php/7.2/fpm/pool.d/www.conf
ENV php_ini /etc/php/7.2/fpm/php.ini

RUN apt-get update && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get -y install php7.2-fpm php7.2 curl \
	php7.2-xsl php-xdebug php-apcu php7.2-intl php-imagick php7.2-gmp php7.2-curl \
	php7.2-xml php7.2-zip php7.2-bz2 php7.2-mbstring php7.2-gd php7.2-ldap php7.2-mysql && \
	apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_* && \
    sed -i \
        -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
        -e "s/pm.max_children = 5/pm.max_children = 50/g" \
        -e "s/pm.start_servers = 2/pm.start_servers = 6/g" \
        -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
        -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 10/g" \
        -e "s/;pm.max_requests = 500/pm.max_requests = 500/g" \
        -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
        -e "s/listen = \/run\/php\/php7.2-fpm.sock/listen = [::]:9000/g" \
        -e "s/^;clear_env = no$/clear_env = no/" \
        ${fpm_conf} && \
  	sed -i \
    	-e "s/;session.save_path = \"\/var\/lib\/php\/sessions\"/session.save_path = \"\/var\/lib\/php\/sessions\"/g" \
    	${php_ini} && \
    mkdir /var/run/php && \
    rm "/etc/php/7.2/fpm/conf.d/20-xdebug.ini"

COPY script/start.sh /usr/local/bin/start.sh


RUN chmod 755 /usr/local/bin/start.sh

EXPOSE 9000

CMD ["/usr/local/bin/start.sh"]
