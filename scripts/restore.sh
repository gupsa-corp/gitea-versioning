#!/bin/bash

# Gitea 복원 스크립트
set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup_date>"
    echo "Example: $0 20240101_120000"
    exit 1
fi

BACKUP_DATE=$1
BACKUP_DIR="./backups"
DUMP_FILE="${BACKUP_DIR}/gitea-dump-${BACKUP_DATE}.zip"
VOLUME_FILE="${BACKUP_DIR}/gitea-volumes-${BACKUP_DATE}.tar.gz"

echo "Starting Gitea restore process..."

# 백업 파일 존재 확인
if [ ! -f "$DUMP_FILE" ]; then
    echo "Error: Dump file not found: $DUMP_FILE"
    exit 1
fi

if [ ! -f "$VOLUME_FILE" ]; then
    echo "Error: Volume backup file not found: $VOLUME_FILE"
    exit 1
fi

echo "Stopping Gitea services..."
docker-compose down

echo "Restoring data volumes..."
docker run --rm \
  -v gitea-data:/data \
  -v gitea-db-data:/dbdata \
  -v $(pwd)/${BACKUP_DIR}:/backup \
  alpine tar xzf /backup/gitea-volumes-${BACKUP_DATE}.tar.gz -C /

echo "Starting services..."
docker-compose up -d

echo "Waiting for services to start..."
sleep 30

echo "Restoring Gitea dump..."
docker cp ${DUMP_FILE} gitea:/tmp/
docker exec gitea gitea restore --from /tmp/$(basename ${DUMP_FILE}) -c /data/gitea/conf/app.ini

echo "Restore completed successfully!"
echo "Please verify that all data has been restored correctly."