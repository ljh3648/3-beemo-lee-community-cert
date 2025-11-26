FROM certbot/dns-cloudflare:v5.1.0

WORKDIR /work

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# RUN ["/entrypoint.sh"]

# ENTRYPOINT ["/bin/sh"]
