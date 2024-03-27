psql -U postgres < /usr/local/share/pgsql/createuser.pgsql
psql -U openidm < /usr/local/share/pgsql/openidm.pgsql
psql -U openidm < /usr/local/share/pgsql/explicit-managed-user.sql