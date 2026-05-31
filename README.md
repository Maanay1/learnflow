# JARQ

JARQ is a dark-first educational social platform built with Phoenix, PostgreSQL, MinIO, Phoenix Channels, SvelteKit, and TailwindCSS. It supports creator uploads, signed private video access, social follows, likes, comments, dashboards, search, AI subtitles/summaries, and GDPR-style user export.

## Screenshots

Screenshots will be added here:

| Landing | Feed | Video |
| --- | --- | --- |
| Placeholder | Placeholder | Placeholder |

## Prerequisites

| Tool | Purpose |
| --- | --- |
| Docker | Runs PostgreSQL, MinIO, Phoenix, and SvelteKit containers |
| Docker Compose | Orchestrates the local stack |
| Elixir and Mix | Local backend development |
| Node.js and npm | Local frontend development |

## Getting Started

```bash
cp .env.example .env
cd infra && ./init.sh
open http://localhost:3000
```

Manual start:

```bash
docker compose -f infra/docker-compose.yml up --build
```

## Environment Variables

| Variable | Description | Example |
| --- | --- | --- |
| `DATABASE_URL` | PostgreSQL connection URL used by Ecto | `ecto://learnflow:devpassword123@localhost:5432/learnflow_dev` |
| `MINIO_ENDPOINT` | S3-compatible MinIO endpoint | `http://localhost:9000` |
| `MINIO_PUBLIC_ENDPOINT` | Browser-accessible S3 endpoint used for signed uploads | `http://localhost:9000` |
| `MINIO_ACCESS_KEY` | MinIO access key | `minioadmin` |
| `MINIO_SECRET_KEY` | MinIO secret key | `minioadmin123` |
| `MINIO_BUCKET_VIDEOS` | Bucket for uploaded video objects | `learnflow-videos` |
| `MINIO_BUCKET_THUMBNAILS` | Bucket for thumbnails | `learnflow-thumbnails` |
| `MINIO_BUCKET_AVATARS` | Bucket for uploaded profile avatars | `jarq-avatars` |
| `OPENAI_API_KEY` | Enables Whisper transcription and GPT summaries/chapters | `sk-...` |
| `GOOGLE_CLIENT_ID` | Google OAuth web client ID | `...apps.googleusercontent.com` |
| `GOOGLE_CLIENT_SECRET` | Google OAuth web client secret | `...` |
| `BACKEND_URL` | Public backend URL used for the Google OAuth callback | `https://learnflow-api-1eef.onrender.com` |
| `SECRET_KEY_BASE` | Phoenix signing/encryption secret | `replace-with-a-strong-64-byte-secret-key-base` |
| `PHX_HOST` | Public Phoenix host | `localhost` |
| `PORT` | Phoenix HTTP port | `4000` |
| `TWILIO_ACCOUNT_SID` | Twilio Account SID for SMS verification | `AC...` |
| `TWILIO_AUTH_TOKEN` | Twilio auth token | `...` |
| `TWILIO_PHONE` | Twilio sender phone number | `+15551234567` |

## Architecture

```text
learnflow/
├── backend/   Phoenix API, Ecto/PostgreSQL, auth, MinIO, Channels
├── frontend/  SvelteKit application with TailwindCSS
├── infra/     Docker Compose and init script
└── README.md
```

## API Documentation

| Method | Endpoint | Description |
| --- | --- | --- |
| `POST` | `/api/auth/register` | Register and create session |
| `POST` | `/api/auth/login` | Login and create session |
| `DELETE` | `/api/auth/logout` | Logout current session |
| `GET` | `/api/auth/me` | Current authenticated user |
| `GET` | `/api/feed` | Paginated video feed |
| `POST` | `/api/videos` | Creator video draft |
| `POST` | `/api/videos/:id/upload-url` | Signed video upload URL |
| `POST` | `/api/videos/:id/thumbnail-url` | Signed thumbnail upload URL |
| `POST` | `/api/videos/:id/confirm` | Confirm upload and activate |
| `POST` | `/api/videos/:id/chapters` | Replace chapters |
| `GET` | `/api/videos/:slug` | Video detail |
| `GET` | `/api/videos/:id/view-url` | Signed private view URL |
| `GET` | `/api/videos/:id/subtitles/:lang` | Signed VTT subtitle URL |
| `POST` | `/api/videos/:id/transcribe` | Queue AI transcription |
| `GET` | `/api/videos/:id/summary` | AI summary |
| `POST` | `/api/videos/:id/progress` | Update watch progress |
| `POST` | `/api/videos/:id/complete` | Mark completed |
| `POST` | `/api/videos/:id/like` | Like video |
| `DELETE` | `/api/videos/:id/like` | Unlike video |
| `POST` | `/api/videos/:id/save` | Save video |
| `DELETE` | `/api/videos/:id/save` | Unsave video |
| `GET` | `/api/videos/:id/comments` | Paginated comments |
| `POST` | `/api/videos/:id/comments` | Create comment or reply |
| `DELETE` | `/api/comments/:id` | Soft-delete comment |
| `POST` | `/api/users/:id/follow` | Follow user |
| `DELETE` | `/api/users/:id/follow` | Unfollow user |
| `GET` | `/api/users/:username` | Public profile with stats |
| `GET` | `/api/users/:username/videos` | Creator videos |
| `GET` | `/api/dashboard/stats` | Learning stats |
| `GET` | `/api/dashboard/history` | Watch history |
| `DELETE` | `/api/dashboard/history/:video_id` | Remove history row |
| `GET` | `/api/dashboard/saved` | Saved videos |
| `GET` | `/api/dashboard/export` | GDPR JSON export |
| `GET` | `/api/recommendations` | Personalized recommendations |
| `GET` | `/api/search` | Full-text search |

## Contributing

1. Create a feature branch.
2. Keep changes focused and covered by tests where possible.
3. Run backend tests with `mix test`.
4. Run frontend checks with `npm run build`.
5. Open a pull request with a short summary and verification notes.

## Production Deployment

### Railway.app

JARQ can be deployed to Railway in a few minutes:

1. Go to [railway.app](https://railway.app).
2. Connect the GitHub repo.
3. Add the PostgreSQL plugin with one click.
4. Set environment variables:

```text
DATABASE_URL=<Railway PostgreSQL URL>
SECRET_KEY_BASE=<strong generated secret>
PHX_HOST=<your Railway public domain>
PORT=4000
FRONTEND_URL=https://<frontend-public-url>
PUBLIC_URL=https://<frontend-public-url>
BACKEND_URL=https://<backend-public-url>
API_PUBLIC_URL=https://<backend-public-url>
MINIO_ENDPOINT=<S3-compatible endpoint>
MINIO_PUBLIC_ENDPOINT=<browser-accessible S3 endpoint>
MINIO_ACCESS_KEY=<S3 access key>
MINIO_SECRET_KEY=<S3 secret key>
MINIO_BUCKET_VIDEOS=learnflow-videos
MINIO_BUCKET_THUMBNAILS=learnflow-thumbnails
MINIO_BUCKET_CERTIFICATES=learnflow-certificates
MINIO_BUCKET_AVATARS=jarq-avatars
OPENAI_API_KEY=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE=
SMTP_HOST=
SMTP_PORT=587
SMTP_USERNAME=
SMTP_PASSWORD=
EMAIL_FROM=JARQ <noreply@learnflow.dev>
COOKIE_SECURE=true
URL_SCHEME=https
```

5. Deploy. Railway will build from the Dockerfile and expose a public URL in about 5 minutes.

### Render

Set these environment variables on the Render backend service:

```text
BACKEND_URL=https://learnflow-api-1eef.onrender.com
FRONTEND_URL=https://jarq.me
```

Add `https://learnflow-api-1eef.onrender.com/auth/google/callback` to the authorized redirect URIs of the Google OAuth web client.

Deploying from the repository root uses [Dockerfile](/Users/bayel/Desktop/JARQ_03/learnflow/Dockerfile) for the backend. For separate backend and frontend Railway services, set the service root directories to `backend` and `frontend` respectively. The backend service can use [backend/Dockerfile](/Users/bayel/Desktop/JARQ_03/learnflow/backend/Dockerfile), and the frontend uses [frontend/Dockerfile](/Users/bayel/Desktop/JARQ_03/learnflow/frontend/Dockerfile) plus [frontend/nginx.conf](/Users/bayel/Desktop/JARQ_03/learnflow/frontend/nginx.conf).

JARQ is configured for a single Ubuntu 24.04 VPS using Docker, GitHub Container Registry, nginx, and GitHub Actions.

### GitHub Secrets

| Secret | Purpose |
| --- | --- |
| `SSH_PRIVATE_KEY` | Private key used by GitHub Actions to SSH into the VPS |
| `VPS_HOST` | VPS IP or hostname |
| `VPS_USER` | SSH user on the VPS |
| `VPS_DOMAIN` | Public domain used for frontend build URLs |
| `DATABASE_URL` | Production Ecto URL |
| `SECRET_KEY_BASE` | Phoenix secret |
| `MINIO_ACCESS_KEY` | MinIO root/access key |
| `MINIO_SECRET_KEY` | MinIO root/secret key |
| `OPENAI_API_KEY` | OpenAI API key for AI features |
| `STRIPE_SECRET_KEY` | Stripe secret key |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signing secret |
| `SMTP_HOST` | SMTP relay host |
| `SMTP_USER` | SMTP username |
| `SMTP_PASSWORD` | SMTP password |

### One-Time VPS Setup

```bash
scp infra/setup-vps.sh infra/docker-compose.prod.yml infra/nginx.conf infra/backup.sh user@your-vps:/tmp/
ssh user@your-vps
cd /tmp
DOMAIN=learnflow.example.com EMAIL=admin@example.com ./setup-vps.sh
cd /opt/learnflow
nano .env.production
docker compose -f docker-compose.prod.yml up -d
```

Replace `learnflow.example.com` in `infra/nginx.conf` or let `setup-vps.sh` replace it from `DOMAIN`.

### Deploy

Push to `main`. The workflow in `.github/workflows/deploy.yml` runs tests, builds `backend` and `frontend` images, pushes them to GHCR with the git SHA and `latest`, SSHes into the VPS, pulls the images, runs migrations, and checks `/health`.

Manual deploy on the VPS:

```bash
cd /opt/learnflow
IMAGE_TAG=<git-sha> docker compose -f docker-compose.prod.yml pull
IMAGE_TAG=<git-sha> docker compose -f docker-compose.prod.yml up -d --no-deps backend frontend nginx
docker compose -f docker-compose.prod.yml exec -T backend /app/bin/learnflow rpc 'Ecto.Migrator.run(Learnflow.Repo, :up, all: true)'
curl -fsS http://localhost:4000/health
```

### Rollback

```bash
cd /opt/learnflow
sed -i 's/^IMAGE_TAG=.*/IMAGE_TAG=<previous-git-sha>/' .env.production
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d --no-deps backend frontend nginx
curl -fsS http://localhost:4000/health
```

### Backups and Restore

Install the daily backup cron:

```bash
sudo cp infra/learnflow-backup.cron /etc/cron.d/learnflow-backup
```

Backups are compressed PostgreSQL dumps uploaded to the MinIO bucket `learnflow-backups`; files older than 30 days are removed automatically.

Restore:

```bash
cd /opt/learnflow
docker run --rm --network learnflow_default -e MC_HOST_local="http://$MINIO_ACCESS_KEY:$MINIO_SECRET_KEY@minio:9000" -v /tmp:/restore minio/mc:latest cp local/learnflow-backups/<backup>.sql.gz /restore/
gunzip -c /tmp/<backup>.sql.gz | docker compose -f docker-compose.prod.yml exec -T postgres psql -U learnflow -d learnflow_prod
```

### Monitoring

Start Prometheus, Grafana, and node-exporter:

```bash
cd /opt/learnflow/monitoring
docker compose -f docker-compose.monitoring.yml up -d
```

Grafana listens on `127.0.0.1:3001` by default. The provisioned dashboard covers health, memory, DB connectivity, process counts, and placeholders for request/upload metrics exposed through `/metrics`.

## License

MIT
