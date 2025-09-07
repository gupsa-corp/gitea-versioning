# Gitea 빠른 시작 가이드

## 🚀 5분만에 Gitea 실행하기

### 1단계: 저장소 클론 및 설정

```bash
git clone https://github.com/gupsa-corp/gitea-versioning.git
cd gitea-versioning

# 환경 설정 파일 생성
make setup

# .env 파일 편집 (필요시)
nano .env
```

### 2단계: 서비스 시작

```bash
# 기본 설정으로 시작
make up

# 또는 nginx 리버스 프록시와 함께 시작
make up-with-nginx
```

### 3단계: 초기 설정

1. 브라우저에서 `http://localhost:3000` 접속
2. 초기 설정 페이지에서 다음 설정:
   - 데이터베이스: PostgreSQL (이미 설정됨)
   - 관리자 계정 생성
   - 기본 설정 확인

### 4단계: 첫 번째 저장소 생성

1. 웹 인터페이스에서 "New Repository" 클릭
2. 저장소 이름 입력
3. README 파일 생성 옵션 선택
4. "Create Repository" 클릭

## 🛠 주요 명령어

```bash
# 서비스 관리
make up          # 서비스 시작
make down        # 서비스 중지
make restart     # 서비스 재시작
make logs        # 로그 확인

# 백업 및 복원
make backup      # 백업 생성
make restore DATE=20240101_120000  # 백업 복원

# 관리
make status      # 서비스 상태 확인
make admin-user USER=admin EMAIL=admin@example.com PASS=password
```

## 📡 Git 원격 저장소 설정

### SSH 사용 (권장)

```bash
# SSH 키 생성 (없는 경우)
ssh-keygen -t ed25519 -C "your-email@example.com"

# 공개키를 Gitea에 등록 (웹 인터페이스 > Settings > SSH Keys)
cat ~/.ssh/id_ed25519.pub

# 저장소 클론
git clone ssh://git@localhost:222/username/repository.git
```

### HTTPS 사용

```bash
# 저장소 클론
git clone http://localhost:3000/username/repository.git

# 자격 증명 저장 (선택사항)
git config --global credential.helper store
```

## 🔧 일반적인 설정

### 이메일 알림 활성화

`.env` 파일에서:
```bash
GITEA_MAILER_ENABLED=true
GITEA_MAILER_FROM=gitea@yourdomain.com
GITEA_MAILER_HOST=smtp.gmail.com:587
GITEA_MAILER_USER=your-email@gmail.com
GITEA_MAILER_PASSWD=your-app-password
```

### 회원가입 비활성화

```bash
GITEA_DISABLE_REGISTRATION=true
```

### HTTPS 활성화

1. SSL 인증서를 `nginx/ssl/` 디렉토리에 배치
2. `nginx/nginx.conf`에서 HTTPS 설정 주석 해제
3. `make up-with-nginx`로 재시작

## 🆘 문제 해결

### 서비스가 시작되지 않는 경우

```bash
# 포트 사용 확인
netstat -tulpn | grep :3000
netstat -tulpn | grep :222

# 로그 확인
make logs

# 서비스 상태 확인
make status
```

### 데이터베이스 연결 문제

```bash
# 데이터베이스 로그 확인
make logs-db

# 데이터베이스 컨테이너 재시작
docker-compose restart gitea-db
```

### 권한 문제

```bash
# 데이터 볼륨 권한 확인
docker exec gitea ls -la /data

# 권한 수정이 필요한 경우
docker exec gitea chown -R git:git /data
```

## 💡 팁

1. **백업 자동화**: cron job으로 정기 백업 설정
2. **모니터링**: `make monitor`로 리소스 사용량 확인
3. **업데이트**: `make update`로 최신 버전 업데이트
4. **로그 관리**: 로그 로테이션 설정 권장

## 🔗 유용한 링크

- [Gitea 공식 문서](https://docs.gitea.io/)
- [API 문서](https://docs.gitea.io/en-us/api-usage/)
- [커뮤니티 지원](https://discourse.gitea.io/)