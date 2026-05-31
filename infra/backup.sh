#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/learnflow}"
BACKUP_BUCKET="${BACKUP_BUCKET:-learnflow-backups}"
DATE="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
FILE="learnflow-${DATE}.sql.gz"

cd "$APP_DIR"

if [ -f .env.production ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env.production
  set +a
fi

echo "Creating PostgreSQL dump..."
docker compose -f docker-compose.prod.yml exec -T postgres pg_dump \
  -U "${POSTGRES_USER:-learnflow}" \
  -d "${POSTGRES_DB:-learnflow_prod}" \
  --no-owner --no-acl | gzip > "/tmp/${FILE}"

echo "Uploading backup to MinIO bucket ${BACKUP_BUCKET}..."
docker run --rm --network learnflow_default \
  -e MC_HOST_local="http://${MINIO_ACCESS_KEY}:${MINIO_SECRET_KEY}@minio:9000" \
  -v "/tmp/${FILE}:/backup/${FILE}:ro" \
  minio/mc:latest sh -c "mc mb --ignore-existing local/${BACKUP_BUCKET} && mc cp /backup/${FILE} local/${BACKUP_BUCKET}/${FILE}"

echo "Deleting backups older than 30 days..."
docker run --rm --network learnflow_default \
  -e MC_HOST_local="http://${MINIO_ACCESS_KEY}:${MINIO_SECRET_KEY}@minio:9000" \
  minio/mc:latest find "local/${BACKUP_BUCKET}" --older-than 30d --exec "mc rm {}"

rm -f "/tmp/${FILE}"
echo "Backup complete: ${FILE}"
