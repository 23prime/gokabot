#!/bin/bash -eu

docker compose build
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/m0z8x5y6
docker push public.ecr.aws/m0z8x5y6/gokabot-core-api:latest
