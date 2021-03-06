# Docker Laravel

Docker laravel setup

## How to develop

1. Have a copy of laravel codebase in `laravel/` directory. We can install it with command 

```shell script
docker run --rm \
    -v ${PWD}:/app \
    -v ${HOME}/.composer:/root/.composer \
    composer create-project --prefer-dist laravel/laravel laravel
```

1. Start the container with command and open with url https://localhost:7100 

```shell script
docker-compose up -d
docker-compose exec app composer install
```

## Notes

`ssl-certificate` directory contains the dummy root certificate. 
The password key is `123456`. Use tutorial from https://github.com/gusdecool/local-cert-generator
to generate new certificate if needed or expired.
