ARG BUILD_ENV
ARG LEDGER_DOCUMENT_ROOT


FROM debian:9 AS build_local
# nothing special to do here. Docroot will be bind-mounted.


FROM debian:9 AS build_prod
ARG LEDGER_DOCUMENT_ROOT
ONBUILD RUN install -d -o www-data -g www-data     ${LEDGER_DOCUMENT_ROOT}
ONBUILD COPY --chown=www-data:www-data ../../../.. ${LEDGER_DOCUMENT_ROOT}




FROM build_${BUILD_ENV}
ARG LEDGER_DOCUMENT_ROOT

RUN sed -ri 's/deb\.debian\.org/ftp.uni-kl.de/g' /etc/apt/sources.list

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
      libyaml-perl \
      libyaml-tiny-perl \
      libcgi-formbuilder-perl \
      libmojolicious-perl \
      libmojolicious-plugin-i18n-perl \
      libmojo-pg-perl \
      postgresql-client \
      zip \
      less \
      atool

RUN apt-get install -y \
    cpanminus \
    make && \
    cpanm DBIx::XHTML_Table

ARG LEDGER_APACHE_RUN_USER
ARG LEDGER_APACHE_RUN_USERID
ARG LEDGER_APACHE_RUN_GROUP
ARG LEDGER_APACHE_RUN_GROUPID

RUN if test "${LEDGER_APACHE_RUN_USER}" != "www-data"; then \
      groupadd -g ${LEDGER_APACHE_RUN_GROUPID} ${LEDGER_APACHE_RUN_GROUP} && \
      useradd  -u ${LEDGER_APACHE_RUN_USERID} -d /nonexistent -M -r \
               -g ${LEDGER_APACHE_RUN_GROUP} \
               -s /bin/false ${LEDGER_APACHE_RUN_USER}; \
    else \
      echo "APACHE_RUN_USER is www-data -- Nothing to do here"; \
    fi
    


ENV APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_PID_FILE=/var/run/apache2/apache2.pid \
    APACHE_RUN_USER=${LEDGER_APACHE_RUN_USER} \
    APACHE_RUN_GROUP=${LEDGER_APACHE_RUN_GROUP} \
    APACHE_LOG_DIR=/var/log/apache2

RUN a2enmod cgi rewrite && \
    a2dissite 000-default && \
    a2disconf other-vhosts-access-log && \
    rm -f /etc/apache2/sites-available/*

COPY apache_sql-ledger.conf /etc/apache2/sites-available/sql-ledger.conf


RUN a2ensite sql-ledger

RUN ln -sf /dev/stderr /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

EXPOSE 80

COPY ledger*.pl  /usr/local/bin/

ENV LEDGER_DOCUMENT_ROOT=${LEDGER_DOCUMENT_ROOT} \
    LEDGER_APACHE_RUN_USER=${LEDGER_APACHE_RUN_USER}


CMD ["apache2", "-DFOREGROUND", "-CServerName localhost"]

