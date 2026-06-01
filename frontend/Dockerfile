FROM node:20-alpine AS build
WORKDIR /app
ARG VITE_API_URL=https://learnflow-api-1eef.onrender.com
ARG VITE_WS_URL=wss://learnflow-api-1eef.onrender.com/socket
ENV VITE_API_URL=$VITE_API_URL
ENV VITE_WS_URL=$VITE_WS_URL
ENV SVELTE_ADAPTER=static
ENV NODE_ENV=development
COPY package*.json ./
RUN npm ci --include=dev --no-audit --no-fund
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 3000
