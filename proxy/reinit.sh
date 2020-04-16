#!/bin/bash

## recreating the proxy-container by removing local image and rebuilding it

cd "${0%/*}"
docker-compose down --rmi local
docker-compose up --build -d