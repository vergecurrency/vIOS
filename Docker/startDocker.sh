#!/bin/bash

# start Docker, if not running
if (! /usr/local/bin/docker stats --no-stream ); then
    open /Applications/Docker.app
    
    while (! /usr/local/bin/docker stats --no-stream ); do
      # Docker takes a few seconds to initialize
      echo "Waiting for Docker to finish launching..."
      sleep 30
    done
    echo "Docker started"
fi
