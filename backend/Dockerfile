FROM elixir:1.16-alpine AS build

RUN apk add --no-cache build-base git
ENV HEX_HTTP_CONCURRENCY=1 \
    HEX_HTTP_TIMEOUT=120
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY . .
RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix phx.gen.release
RUN MIX_ENV=prod mix release

FROM alpine:3.18 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs
WORKDIR /app

ENV HOME=/app \
    MIX_ENV=prod

COPY --from=build /app/_build/prod/rel/learnflow ./
RUN printf '#!/bin/sh\nif [ "$1" = "phx.server" ]; then exec /app/bin/learnflow start; fi\necho "This Railway image is a Phoenix release. Use: bin/learnflow start" >&2\nexit 1\n' > /usr/local/bin/mix \
  && chmod +x /usr/local/bin/mix

EXPOSE 4000
CMD ["bin/learnflow", "start"]
