FROM debian:9
# (We could not use 9-slim because of problems installing  postgresql-client)


RUN apt-get update  && \  
    apt-get install -y \
      apache2 \
      libdbi-perl \
      libdbd-pg-perl \
      libdbix-simple-perl \
      libgd-graph-perl \
      libxml-libxml-perl \
      libfile-pushd-perl \
      libtext-csv-xs-perl \
      libopenoffice-oodoc-perl \
      libyaml-tiny-perl \
      libcgi-formbuilder-perl \
      libmojolicious-perl \
      libmojolicious-plugin-i18n-perl \
      libmojo-pg-perl \
      postgresql-client \
      zip \
      atool


ENV APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_PID_FILE=/var/run/apache2/apache2.pid \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2

RUN a2enmod cgi rewrite && \
    a2dissite 000-default && \
    a2disconf other-vhosts-access-log && \
    rm -f /etc/apache2/sites-available/*

COPY .cicd/compose/build/web/sql-ledger.conf  /etc/apache2/sites-available


RUN mkdir -p /srv/www/sql-ledger


COPY . /srv/www/sql-ledger
RUN chown -R www-data:www-data /srv/www/sql-ledger
#RUN chown www-data:www-data /srv/www/sql-ledger

RUN a2ensite sql-ledger

RUN ln -sf /dev/stderr /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

EXPOSE 80

COPY .cicd/compose/build/web/ledgersetup.pl  /usr/local/bin

CMD ["apache2", "-DFOREGROUND", "-CServerName localhost"]
