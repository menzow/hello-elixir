FROM node:8 as web-build

# Cache node_modules in tmp and only re-downlaod when package.json is changed.
ADD web/package.json /tmp/package.json
RUN cd /tmp && npm install --verbose

# Copy node_modules to web directory
RUN mkdir -p '/opt/web' && cp -a '/tmp/node_modules'  '/opt/web/'

WORKDIR /opt/web

# Build application
ADD web .
RUN npm run-script build

FROM bitwalker/alpine-elixir-phoenix:latest

# Default database config. Strongly adviced to override
ENV DATABASE_NAME=postgres DATABASE_USER=postgres DATABASE_PASSWORD=hello-elixir

# Set exposed ports
EXPOSE 4000
ENV PORT=4000 MIX_ENV=dev

# Cache elixir deps
ADD app/mix.exs app/mix.lock ./
RUN mix do deps.get, deps.compile

ADD app/config/dev.exs config/dev.exs

ADD app .
# Run frontend build, compile, and digest assets
COPY --from=web-build /opt/web/build ./priv/static
RUN mix do compile, phx.digest

USER default

CMD ["mix", "phx.server"]