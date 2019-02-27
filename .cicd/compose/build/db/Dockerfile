FROM postgres:9.6

RUN apt-get update && \  
    apt-get install -y \
    less

RUN localedef -f ISO-8859-1 -i de_DE de_CH.ISO-8859-1


COPY change-settings.sh /docker-entrypoint-initdb.d/
RUN chmod 755 /docker-entrypoint-initdb.d/change-settings.sh

COPY pg_purgeall.sh /usr/local/bin
RUN chmod 755 /usr/local/bin/pg_purgeall.sh
