#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${DOMAIN:-learnflow.example.com}"
EMAIL="${EMAIL:-admin@example.com}"
APP_DIR="/opt/learnflow"

echo "Updating Ubuntu 24.04 packages..."
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

echo "Installing Docker, Compose, nginx, certbot and firewall tools..."
sudo apt-get install -y ca-certificates curl gnupg ufw nginx certbot python3-certbot-nginx logrotate
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Creating JARQ directories..."
sudo mkdir -p "$APP_DIR" /var/www/certbot /opt/learnflow/backups
sudo chown -R "$USER:$USER" "$APP_DIR"

if [ -f docker-compose.prod.yml ]; then cp docker-compose.prod.yml "$APP_DIR/docker-compose.prod.yml"; fi
if [ -f nginx.conf ]; then cp nginx.conf "$APP_DIR/nginx.conf"; fi
if [ -f backup.sh ]; then cp backup.sh "$APP_DIR/backup.sh"; chmod +x "$APP_DIR/backup.sh"; fi

if [ ! -f "$APP_DIR/.env.production" ]; then
  cat > "$APP_DIR/.env.production" <<ENV
DOMAIN=$DOMAIN
GHCR_REPOSITORY=owner/learnflow
IMAGE_TAG=latest
POSTGRES_DB=learnflow_prod
POSTGRES_USER=learnflow
POSTGRES_PASSWORD=change-me
DATABASE_URL=ecto://learnflow:change-me@postgres:5432/learnflow_prod
SECRET_KEY_BASE=replace-with-strong-secret
BACKEND_URL=https://$DOMAIN
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=replace-with-strong-minio-secret
MINIO_PUBLIC_ENDPOINT=https://storage.example.com
MINIO_BUCKET_VIDEOS=learnflow-videos
MINIO_BUCKET_THUMBNAILS=learnflow-thumbnails
MINIO_BUCKET_CERTIFICATES=learnflow-certificates
MINIO_BUCKET_AVATARS=jarq-avatars
OPENAI_API_KEY=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
SMTP_HOST=
SMTP_PORT=587
SMTP_USERNAME=
SMTP_PASSWORD=
EMAIL_FROM=JARQ <noreply@$DOMAIN>
ENV
fi

echo "Configuring nginx host and SSL..."
sudo sed -i "s/learnflow.example.com/$DOMAIN/g" "$APP_DIR/nginx.conf"
sudo cp "$APP_DIR/nginx.conf" /etc/nginx/conf.d/learnflow.conf
sudo nginx -t
sudo systemctl reload nginx
sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL" --redirect

echo "Creating systemd unit..."
sudo tee /etc/systemd/system/learnflow.service >/dev/null <<SERVICE
[Unit]
Description=JARQ Docker Compose stack
Requires=docker.service
After=docker.service network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/docker compose -f docker-compose.prod.yml up -d
ExecStop=/usr/bin/docker compose -f docker-compose.prod.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable learnflow.service

echo "Configuring Docker logrotate fallback..."
sudo tee /etc/logrotate.d/learnflow-docker >/dev/null <<ROTATE
/var/lib/docker/containers/*/*.log {
  rotate 7
  daily
  compress
  size=50M
  missingok
  delaycompress
  copytruncate
}
ROTATE

echo "Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

echo "VPS setup complete. Edit $APP_DIR/.env.production, then run:"
echo "cd $APP_DIR && docker compose -f docker-compose.prod.yml up -d"
