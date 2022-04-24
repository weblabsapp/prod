#!/usr/bin/env bash

# Copy .env.(env) to .env for docker-compose
echo "Building weblabs-app:prod docker image..."

echo "Executing docker-compose build --no-cache --force-rm"
docker-compose build --no-cache --force-rm

if $? neq 0; then
  echo "Building image failed. Exiting ..."
  exit 1;
fi

echo "Done building image. Running containers up."
echo "Executing docker-compose up -d"
docker-compose up -d