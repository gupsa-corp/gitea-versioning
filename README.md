# Gitea - 경량 Git 호스팅 서비스

Gitea는 Go로 작성된 경량화된 DevOps 플랫폼입니다. Git 호스팅, 이슈 추적, CI/CD 등의 기능을 제공하며, 자체 호스팅이 가능한 GitHub 대안입니다.

## 🚀 주요 특징

### 장점
- **경량화**: 수백 MB ~ 1GB의 적은 리소스 사용
- **쉬운 설치**: Docker, 바이너리, 패키지 매니저를 통한 간단한 설치
- **Git 프로토콜 지원**: SSH 및 HTTP(S) 프로토콜 완벽 지원
- **권한 관리**: 세밀한 사용자/팀 권한 관리 시스템
- **Webhook 지원**: 다양한 이벤트에 대한 웹훅 기능
- **REST API**: 완전한 REST API 제공
- **다중 데이터베이스**: SQLite, MySQL, PostgreSQL 지원

### 한계점
- GitLab 대비 내장 CI/CD 기능이 제한적 (별도 CI Runner 필요)
- 고급 DevOps 기능은 외부 도구 연동 필요

## 📋 요구사항

- Docker & Docker Compose
- 최소 512MB RAM (권장: 1GB 이상)
- 1GB 이상의 디스크 공간

## 🛠 설치 및 실행

### Docker Compose를 사용한 설치 (권장)

```bash
# 저장소 클론
git clone <repository-url>
cd gitea

# 환경 변수 설정
cp .env.example .env
# .env 파일을 편집하여 필요한 설정값 입력

# 서비스 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f gitea
```

### 수동 Docker 설치

```bash
# Gitea 컨테이너 실행
docker run -d \
  --name gitea \
  -p 3000:3000 \
  -p 222:22 \
  -v gitea-data:/data \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/localtime:/etc/localtime:ro \
  gitea/gitea:latest
```

## 🔧 설정

### 초기 설정

1. 브라우저에서 `http://localhost:3000` 접속
2. 초기 관리자 계정 생성
3. 데이터베이스 설정 (SQLite/MySQL/PostgreSQL)
4. 기본 설정 구성

### 고급 설정

설정 파일은 `data/gitea/conf/app.ini`에 위치합니다. 주요 설정 항목:

```ini
[server]
DOMAIN = localhost
HTTP_PORT = 3000
ROOT_URL = http://localhost:3000/

[database]
DB_TYPE = sqlite3
PATH = /data/gitea/gitea.db

[security]
INSTALL_LOCK = true
SECRET_KEY = your-secret-key
```

## 🌐 네트워크 설정

### 포트 매핑
- **3000**: HTTP 웹 인터페이스
- **222**: SSH Git 접근 (호스트의 22번 포트와 충돌 방지)

### 방화벽 설정
```bash
# UFW를 사용하는 경우
sudo ufw allow 3000
sudo ufw allow 222
```

## 👥 사용자 관리

### 관리자 계정 생성
```bash
# 컨테이너 내에서 실행
docker exec -it gitea gitea admin user create \
  --username admin \
  --password admin123 \
  --email admin@example.com \
  --admin
```

### 조직 및 팀 관리
1. 웹 인터페이스에서 조직 생성
2. 팀 생성 및 권한 설정
3. 사용자를 팀에 할당

## 🔄 백업 및 복원

### 백업
```bash
# 데이터 디렉토리 백업
docker exec gitea gitea dump -c /data/gitea/conf/app.ini

# 또는 볼륨 백업
docker run --rm -v gitea-data:/data -v $(pwd):/backup alpine \
  tar czf /backup/gitea-backup.tar.gz /data
```

### 복원
```bash
# 볼륨 복원
docker run --rm -v gitea-data:/data -v $(pwd):/backup alpine \
  tar xzf /backup/gitea-backup.tar.gz -C /
```

## 🔧 CI/CD 통합

Gitea는 기본적인 CI/CD 기능이 제한적이므로 외부 도구 연동이 필요합니다:

### Gitea Actions (내장 CI/CD)
```yaml
# .gitea/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test
```

### 외부 CI 도구 연동
- **Jenkins**: Webhook을 통한 빌드 트리거
- **Drone**: Gitea 네이티브 지원
- **GitHub Actions**: 미러링을 통한 연동

## 📊 모니터링

### 로그 확인
```bash
# Docker Compose 로그
docker-compose logs -f gitea

# 특정 시간부터의 로그
docker-compose logs --since="2h" gitea
```

### 성능 모니터링
```bash
# 리소스 사용량 확인
docker stats gitea

# 디스크 사용량
docker exec gitea du -sh /data
```

## 🛡️ 보안

### SSL/TLS 설정
```yaml
# docker-compose.yml에서 리버스 프록시 사용
version: '3'
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
```

### 방화벽 및 접근 제어
```ini
[service]
DISABLE_REGISTRATION = true
REQUIRE_SIGNIN_VIEW = true

[security]
MIN_PASSWORD_LENGTH = 8
PASSWORD_COMPLEXITY = lower,upper,digit,spec
```

## 🔍 트러블슈팅

### 일반적인 문제

1. **포트 충돌**
   ```bash
   # 포트 사용 확인
   netstat -tulpn | grep :3000
   ```

2. **권한 문제**
   ```bash
   # 데이터 디렉토리 권한 확인
   ls -la data/
   sudo chown -R 1000:1000 data/
   ```

3. **데이터베이스 연결 실패**
   ```bash
   # 데이터베이스 컨테이너 상태 확인
   docker-compose ps
   docker-compose logs db
   ```

## 📚 추가 자료

- [Gitea 공식 문서](https://docs.gitea.io/)
- [Gitea GitHub 저장소](https://github.com/go-gitea/gitea)
- [커뮤니티 포럼](https://discourse.gitea.io/)

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.