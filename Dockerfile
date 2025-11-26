FROM certbot/dns-cloudflare:v5.1.0

WORKDIR /app

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]