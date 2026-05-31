# Как настроить Google Auth

1. Зайди на console.cloud.google.com
2. Создай новый проект "JARQ"
3. APIs & Services → Credentials → Create OAuth 2.0 Client
4. Application type: Web application
5. Authorized redirect URIs добавь:
   http://localhost:4000/auth/google/callback
   https://твой-домен.me/auth/google/callback
6. Скопируй Client ID и Client Secret
7. Добавь в .env файл:
   GOOGLE_CLIENT_ID=вставь_сюда
   GOOGLE_CLIENT_SECRET=вставь_сюда
8. Перезапусти: docker compose -f infra/docker-compose.yml up -d --force-recreate backend
