FROM node:20-alpine AS build
WORKDIR /app
ARG VITE_API_URL=http://localhost:4000
ARG VITE_WS_URL=ws://localhost:4000/socket
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
