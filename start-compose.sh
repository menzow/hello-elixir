#!/bin/sh
docker-compose -f stack.yml up -d
docker-compose -f stack.yml exec app mix do ecto.create, ecto.migrate