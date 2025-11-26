#!/bin/sh

# 환경변수 한 번에 확인
echo -n "Check environment variables"
if [ -z "$CLOUDFLARE_API_TOKEN" ] || [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
	echo "Error: 필수 환경변수가 없습니다 (CLOUDFLARE_API_TOKEN, DOMAIN, EMAIL)"
	exit 1
fi
echo "...[v]"

# cloudflare.ini 생성
echo -n "Check cloudflare.ini"
if [ ! -f "/app/.cloudflare/cloudflare.ini" ]; then
	echo "...[x]"
	echo -n "Make cloudflare.ini"

	# 파일 생성
	mkdir -p /app/.cloudflare
	echo "dns_cloudflare_api_token = $CLOUDFLARE_API_TOKEN" >/app/.cloudflare/cloudflare.ini
	chmod 600 /app/.cloudflare/cloudflare.ini

	# 성공 여부 확인
	if [ -f "/app/.cloudflare/cloudflare.ini" ]; then
		echo "...[v]"
	else
		echo "ERROR: cloudflare.ini 생성에 실패했습니다. /app/.cloudflare/cloudflare.ini"
		exit 1
	fi
else
	echo "...[v]"
fi

# 인증서가 없으면 발급
echo -n "Check Let's encrypt certificate"
if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
	LOG_FILE="/app/logs/certbot_issue.log"

	mkdir -p /app/.cloudflare
	mkdir -p /app/logs

	# 로그를 파일에만 저장 (화면에 출력 안 함)
	certbot certonly --dns-cloudflare \
		--config-dir /app/letsencrypt \
		--work-dir /app/letsencrypt/work \
		--logs-dir /app/letsencrypt/logs \
		--dns-cloudflare-credentials /app/.cloudflare/cloudflare.ini \
		--non-interactive \
		--agree-tos \
		-m "$EMAIL" \
		-d "*.$DOMAIN" \
		-d "$DOMAIN" >"$LOG_FILE" 2>&1

	# 성공/실패 확인
	if [ $? -eq 0 ]; then
		echo "...[v]"
	else
		echo "...[x]"
		echo "ERROR: Let's encrypt 인증서 발급에 실패했습니다."
		cat "$LOG_FILE"
		exit 1
	fi
else
	echo "...[v]"
fi

# 인증서 갱신 루프 시작
while true; do
	echo "loop..."
	certbot renew \
		--config-dir /app/letsencrypt
	sleep 86400 # 24시간마다 체크
done
