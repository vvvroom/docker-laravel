# Docker Laravel

# How to develop

1. Have a copy of laravel codebase in `/laravel/` directory. We can install it with command `composer create-project --prefer-dist laravel/laravel laravel`

# How to run in single container

The container is expecting the root codebase is located at `/var/www/app` and `/var/www/app/public` is the location
where web server for serving at.

To do so, we will need mount our Laravel root codebase to `/var/www` directory. Example in this case, the root
of Laravel code is located at `/laravel` dir. Then the command to run the container will looks like this:

```shell script
docker run --rm \
    -v ${PWD}/laravel:/var/www/app \
    -v ${HOME}/.composer:/root/.composer \
    -p 7100:443 vvvroom/laravel
``` 

If this is the first time we run the application, the first command we may want to do probably `composer install`

# Docker commands

## Build

```shell script
docker build -t vvvroom/laravel .
```

## Run

```shell script
docker run --rm \
    -v ${PWD}/laravel:/var/www/app \
    -v ${HOME}/.composer:/root/.composer \
    -p 7100:443 vvvroom/laravel
```

## Push

```shell script
docker push vvvroom/laravel
```
