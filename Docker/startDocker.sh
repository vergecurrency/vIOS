#!/bin/bash

# start Docker, if not running
if (! docker stats --no-stream ); then
    open /Applications/Docker.app

while (! docker stats --no-stream ); do
  # Docker takes a few seconds to initialize
  echo "Waiting for Docker to finish launching..."
  sleep 5

echo "Docker started"
done
fi
