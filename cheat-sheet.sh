#!/usr/bin/env bash

# Build
docker build -t gusdecool/laravel .

# Push
docker push gusdecool/laravel

# Run
docker run --rm \
    -v ${PWD}/laravel:/var/www/app \
    -v ${HOME}/.composer:/root/.composer \
    -p 8000:80 gusdecool/laravel
