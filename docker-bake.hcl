## Documentation:
## https://docs.docker.com/build/ci/github-actions/multi-platform/#with-bake

variable "DEFAULT_TAG" { default = "wayofdev/php-dev:local" }

## Special target: https://github.com/docker/metadata-action#bake-definition
target "docker-metadata-action" {
    tags = ["${DEFAULT_TAG}"]
}

###########################
##    PHP 8.1
###########################
target "php-81-cli-alpine" {
    inherits = ["docker-metadata-action"]
    context = "dist/dev/8.1-cli-alpine"
    dockerfile = "./Dockerfile"
}

target "php-81-fpm-alpine" {
    inherits = ["docker-metadata-action"]
    context = "dist/dev/8.1-fpm-alpine"
    dockerfile = "./Dockerfile"
}

target "php-81-supervisord-alpine" {
    inherits = ["docker-metadata-action"]
    context = "dist/dev/8.1-supervisord-alpine"
    dockerfile = "./Dockerfile"
}

###########################
##    PHP 8.2
###########################
target "php-82-cli-alpine" {
    inherits = ["docker-metadata-action"]
    context = "dist/dev/8.2-cli-alpine"
    dockerfile = "./Dockerfile"
}

target "php-82-fpm-alpine" {
    inherits = ["docker-metadata-action"]
    context = "dist/dev/8.2-fpm-alpine"
    dockerfile = "./Dockerfile"
}

target "php-82-supervisord-alpine" {
    inherits = ["docker-metadata-action"]
    context = "dist/dev/8.2-supervisord-alpine"
    dockerfile = "./Dockerfile"
}

###########################
##    PHP 8.3
###########################
target "php-83-cli-alpine" {
    inherits = ["docker-metadata-action"]
    context = "dist/dev/8.3-cli-alpine"
    dockerfile = "./Dockerfile"
}

target "php-83-fpm-alpine" {
    inherits = ["docker-metadata-action"]
    context = "dist/dev/8.3-fpm-alpine"
    dockerfile = "./Dockerfile"
}

target "php-83-supervisord-alpine" {
    inherits = ["docker-metadata-action"]
    context = "dist/dev/8.3-supervisord-alpine"
    dockerfile = "./Dockerfile"
}

group "all" {
    targets = [
        "php-81-cli-alpine",
        "php-81-fpm-alpine",
        "php-81-supervisord-alpine",
        "php-82-cli-alpine",
        "php-82-fpm-alpine",
        "php-82-supervisord-alpine",
        "php-83-cli-alpine",
        "php-83-fpm-alpine",
        "php-83-supervisord-alpine",
    ]
}

group "php-81" {
    targets = [
        "php-81-cli-alpine",
        "php-81-fpm-alpine",
        "php-81-supervisord-alpine",
    ]
}

group "php-82" {
    targets = [
        "php-82-cli-alpine",
        "php-82-fpm-alpine",
        "php-82-supervisord-alpine",
    ]
}

group "php-83" {
    targets = [
        "php-83-cli-alpine",
        "php-83-fpm-alpine",
        "php-83-supervisord-alpine",
    ]
}
