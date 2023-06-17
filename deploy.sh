#!/bin/bash -eu

docker compose build
aws lightsail push-container-image \
    --region ap-northeast-1 \
    --service-name gokabot-core-api \
    --label gokabot-core \
    --image gokabot-core:latest
