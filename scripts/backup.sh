#!/bin/bash

# Gitea 백업 스크립트
set -e

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="gitea_backup_${DATE}.tar.gz"

echo "Starting Gitea backup..."

# 백업 디렉토리 생성
mkdir -p ${BACKUP_DIR}

# Gitea dump 실행
echo "Creating Gitea dump..."
docker exec gitea gitea dump -c /data/gitea/conf/app.ini -f /tmp/gitea-dump-${DATE}.zip

# 컨테이너에서 백업 파일 복사
echo "Copying backup file from container..."
docker cp gitea:/tmp/gitea-dump-${DATE}.zip ${BACKUP_DIR}/

# 데이터 볼륨 백업
echo "Backing up data volumes..."
docker run --rm \
  -v gitea-data:/data \
  -v gitea-db-data:/dbdata \
  -v $(pwd)/${BACKUP_DIR}:/backup \
  alpine tar czf /backup/gitea-volumes-${DATE}.tar.gz /data /dbdata

echo "Backup completed: ${BACKUP_DIR}/gitea-dump-${DATE}.zip"
echo "Volume backup: ${BACKUP_DIR}/gitea-volumes-${DATE}.tar.gz"

# 오래된 백업 파일 정리 (7일 이상된 파일 삭제)
echo "Cleaning up old backups..."
find ${BACKUP_DIR} -name "gitea_*" -mtime +7 -delete

echo "Backup process finished!"