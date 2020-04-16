FROM haproxy:latest

# copy our config at the right place
COPY config.cfg /usr/local/etc/haproxy/haproxy.cfg
# (optional): copy custom html-files
COPY html-files /etc/haproxy/errors/

# expose a volume
VOLUME [ "/certs/live" ]

# http, https & stats-port
EXPOSE 80
EXPOSE 443
EXPOSE 8404