FROM postgres:15
RUN mkdir -p /usr/local/share/pgsql
COPY createuser.pgsql /usr/local/share/pgsql/
COPY openidm.pgsql /usr/local/share/pgsql/
COPY explicit-managed-user.sql /usr/local/share/pgsql/

COPY initdb.sh /docker-entrypoint-initdb.d/
