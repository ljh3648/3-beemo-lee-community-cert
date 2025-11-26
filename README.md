인증서를 관리하기 위한 컨테이너

일단 인증서는 자동으로 dns 레코드에 등록해서 검증해주는 플러그인 사용할거임

이미지 빌드
docker build -t community-cert:v0.0.1

컨테이너 실행

./community-cert/etc/letsencrypt:/etc/letsencrypt

docker run -it \
    -v $(pwd):/work \
    -v $(pwd)/etc/letsencrypt:/etc/letsencrypt \
    -v $(pwd)/.cloudflare:/root/.cloudflare:ro \
    community-cert:v0.0.1


이거 만들었으니까 이제 인증서 관리 배치파일을 만들어야 하는건가?

1. 일단 인증서 초기 발급 과정이 필요할거고
근데 발급 받기전에 발급 파일이 있는지 확인히 필요할거고

2. 인증서 기간을 확인해서 재발급 받는 과정이 필요할듯.
기존 인증서 분석해서 재발급 받는 과정


일단 cloudflare.ini 설정 파일을 마운팅하기.
~/.cloudfalre.ini/cloudflare.ini  

-v $(pwd)/.cloudflare:/root/.cloudflare:ro \


certbot certonly --dns-cloudflare \
    --dns-cloudflare-credentials /root/.cloudflare/cloudflare.ini \
    --non-interactive \
    --agree-tos \
    -m ljh09060@gmail.com \
    -d '*.idontwannabeyouanymore.com' \
    -d 'idontwannabeyouanymore.com'


인증서를 받아서 work 디렉토리에 옮겼다.

그다음은 뭐해야하지?

이 발급 자체는 프로젝트가 완전 처음 실행될때 해야하는건데 dockerfile

entrypoint.sh 스크립트 파일로 작성해서 
