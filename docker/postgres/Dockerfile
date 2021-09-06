FROM postgres:10.3

RUN echo "listen_addresses='*' /ntcpip_socket = true" >> /usr/share/postgresql/postgresql.conf
# RUN echo "listen_addresses='*' /ntcpip_socket = true" >> /usr/share/postgresql/10.3/postgresql.conf
RUN echo "max_connections = 300" >> /usr/share/postgresql/postgresql.conf
# RUN echo "max_connections = 300" >> /usr/share/postgresql/10.3/postgresql.conf
RUN echo "shared_buffers = 80MB" >> /usr/share/postgresql/postgresql.conf
# RUN echo "shared_buffers = 80MB" >> /usr/share/postgresql/10.3/postgresql.conf
RUN echo "host all all 0.0.0.0 255.255.255.0 trust" >> /usr/share/postgresql/pg_hba.conf

EXPOSE 5432
