<p align="center">
    <br>
    <a href="https://wayof.dev" target="_blank">
        <picture>
            <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/wayofdev/.github/master/assets/logo.gh-dark-mode-only.png">
            <img width="400" src="https://raw.githubusercontent.com/wayofdev/.github/master/assets/logo.gh-light-mode-only.png" alt="WayOfDev Logo">
        </picture>
    </a>
    <br>
</p>

<p align="center">
<a href="https://actions-badge.atrox.dev/wayofdev/docker-php-dev/goto"><img alt="Build Status" src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fwayofdev%2Fdocker-php-dev%2Fbadge&style=flat-square"/></a>
<a href="https://github.com/wayofdev/docker-php-dev/tags"><img src="https://img.shields.io/github/v/tag/wayofdev/docker-php-dev?sort=semver&style=flat-square" alt="Latest Version"></a>
<a href="https://hub.docker.com/repository/docker/wayofdev/php-dev"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/wayofdev/php-dev?style=flat-square"></a>
<a href="LICENSE.md"><img src="https://img.shields.io/github/license/wayofdev/docker-php-dev.svg?style=flat-square&color=blue" alt="Software License"/></a>
<a href="#"><img alt="Commits since latest release" src="https://img.shields.io/github/commits-since/wayofdev/docker-php-dev/latest?style=flat-square"></a>
</p>

<br>

# Docker Image: PHP Dev(el)

This project provides Docker images for PHP development environments, built on top of the [wayofdev/docker-php-base](https://github.com/wayofdev/docker-php-base) images. It's designed to offer a convenient, feature-rich alternative to Laravel Sail for local development.

<br>

If you **like/use** this package, please consider ⭐️ **starring** it. Thanks!

<br>

## 🚀 Features

- **Based on wayofdev/docker-php-base:** Inherits all features and extensions from the base image.
- **PHP Versions:** Supports PHP `8.1`, `8.2`, `8.3`, and `8.4`.
- **Image Types:** Available in CLI, FPM, and Supervisord variants.
- **Xdebug:** Pre-installed and configured for debugging.
- **Development Tools:** Includes `git`, `bash`, `unzip`, `nano`, and more.
- **Composer:** Pre-installed for PHP dependency management.
- **Time Manipulation:** Includes `libfaketime` for testing time-dependent code.
- **Service Readiness:** Includes `wait4x` for checking service availability.
- **Multi-architecture:** Built for both **AMD64** and **ARM64** architectures.

<br>

## 📦 Additional PHP Extensions

On top of the extensions provided by the base image, this development image includes:

| Extension | Description         | Type |
|-----------|---------------------|------|
| xdebug    | Debugging extension | pecl |

<br>

## 🛠 Included Development Tools

| Package                                           | Type |
|---------------------------------------------------|------|
| git                                               | apk  |
| bash                                              | apk  |
| unzip                                             | apk  |
| nano                                              | apk  |
| [faketime](https://github.com/wolfcw/libfaketime) | apk  |
| [wait4x](https://github.com/atkrad/wait4x)        | apk  |
| composer                                          | bin  |

<br>

## 🚀 Usage

### → Pulling the Image

```bash
docker pull wayofdev/php-dev:8.3-fpm-alpine-latest
```

Replace `8.3-fpm-alpine-latest` with your desired PHP version, type, and tag.

### → Available Image Variants

- **PHP Versions:** 8.1, 8.2, 8.3, 8.4
- **Types:** cli, fpm, supervisord
- **Architectures:** amd64, arm64

#### Examples

```bash
# PHP 8.1 CLI
docker pull wayofdev/php-dev:8.1-cli-alpine-latest

# PHP 8.2 FPM
docker pull wayofdev/php-dev:8.2-fpm-alpine-latest

# PHP 8.3 with Supervisord
docker pull wayofdev/php-dev:8.3-supervisord-alpine-latest
```

### → Using in Docker Compose

Here's a more comprehensive example `docker-compose.yml` for a Laravel project with additional services:

```yaml
services:
  app:
    image: wayofdev/php-dev:8.3-fpm-alpine-latest
    container_name: ${COMPOSE_PROJECT_NAME}-app
    restart: on-failure
    networks:
      - default
      - shared
    depends_on:
      - database
    links:
      - database
    volumes:
      - ./.github/assets:/assets:rw,cached
      - ./app:/app:rw,cached
      - ./.env:/app/.env
      - ~/.composer:/.composer
      - ~/.ssh:/home/www-data/.ssh
    environment:
      FAKETIME: '+2h'
      XDEBUG_MODE: '${XDEBUG_MODE:-off}'
      PHIVE_HOME: /app/.phive
    dns:
      - 8.8.8.8
    extra_hosts:
      - 'host.docker.internal:host-gateway'

  web:
    image: wayofdev/nginx:k8s-alpine-latest
    container_name: ${COMPOSE_PROJECT_NAME}-web
    restart: on-failure
    networks:
      - default
      - shared
    depends_on:
      - app
    links:
      - app
    volumes:
      - ./app:/app:rw,cached
      - ./.env:/app/.env
    labels:
      - traefik.enable=true
      - traefik.http.routers.api-${COMPOSE_PROJECT_NAME}-secure.rule=Host(`api.${COMPOSE_PROJECT_NAME}.docker`)
      - traefik.http.routers.api-${COMPOSE_PROJECT_NAME}-secure.entrypoints=websecure
      - traefik.http.routers.api-${COMPOSE_PROJECT_NAME}-secure.tls=true
      - traefik.http.services.api-${COMPOSE_PROJECT_NAME}-secure.loadbalancer.server.port=8880
      - traefik.docker.network=network.${SHARED_SERVICES_NAMESPACE}
```

#### This configuration includes

- An `app` service using the `wayofdev/php-dev` image for PHP processing.
- A `web` service using a [custom Nginx image](https://github.com/wayofdev/docker-nginx) for serving the application.
- Network configuration for both default and shared networks.
- Volume mounts for application code, assets, and configuration files.
- Environment variables for PHP and Xdebug configuration.
- Traefik labels for reverse proxy and SSL termination.

#### Real-world Example

For a comprehensive, real-world example of how to use this image in a Docker Compose setup, please refer to the [wayofdev/laravel-starter-tpl](https://github.com/wayofdev/laravel-starter-tpl) repository. This template provides a fully configured development environment for Laravel projects using the `wayofdev/php-dev` image.

<br>

## 🔨 Development

This project uses a set of tools for development and testing. The `Makefile` provides various commands to streamline the development process.

### → Requirements

- Docker
- Make
- Ansible
- goss and dgoss for testing

### → Setting Up the Development Environment

Clone the repository:

```bash
git clone git@github.com:wayofdev/docker-php-dev.git && \
cd docker-php-dev
```

### → Generating Dockerfiles

Ansible is used to generate Dockerfiles and configurations. To generate distributable Dockerfiles from Jinja template source code:

```bash
make generate
```

### → Building Images

- Build the default image:

  ```bash
  make build
  ```

  This command builds the image specified by the `IMAGE_TEMPLATE` variable in the Makefile. By default, it's set to `8.3-fpm-alpine`.

- Build a specific image:

  ```bash
  make build IMAGE_TEMPLATE="8.3-fpm-alpine"
  ```

  Replace `8.3-fpm-alpine` with your desired PHP version, type, and OS.

- Build all images:

  ```bash
  make build IMAGE_TEMPLATE="8.1-cli-alpine"
  make build IMAGE_TEMPLATE="8.1-fpm-alpine"
  make build IMAGE_TEMPLATE="8.1-supervisord-alpine"
  make build IMAGE_TEMPLATE="8.2-cli-alpine"
  make build IMAGE_TEMPLATE="8.2-fpm-alpine"
  make build IMAGE_TEMPLATE="8.2-supervisord-alpine"
  make build IMAGE_TEMPLATE="8.3-cli-alpine"
  make build IMAGE_TEMPLATE="8.3-fpm-alpine"
  make build IMAGE_TEMPLATE="8.3-supervisord-alpine"
  make build IMAGE_TEMPLATE="8.4-cli-alpine"
  make build IMAGE_TEMPLATE="8.4-fpm-alpine"
  make build IMAGE_TEMPLATE="8.4-supervisord-alpine"
  ```

  These commands will build all supported image variants.

<br>

## 🧪 Testing

This project uses a testing approach to ensure the quality and functionality of the Docker images. The primary testing tool is [dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss), which allows for testing Docker containers.

### → Running Tests

You can run tests using the following commands:

- Test the default image:

  ```bash
  make test
  ```

  This command tests the image specified by the `IMAGE_TEMPLATE` variable in the Makefile (default is `8.3-fpm-alpine`).

- Test a specific image:

  ```bash
  make test IMAGE_TEMPLATE="8.3-fpm-alpine"
  ```

  Replace `8.3-fpm-alpine` with your desired PHP version, type, and OS.

- Test all images:

  ```bash
  make test IMAGE_TEMPLATE="8.1-cli-alpine"
  make test IMAGE_TEMPLATE="8.1-fpm-alpine"
  make test IMAGE_TEMPLATE="8.1-supervisord-alpine"
  make test IMAGE_TEMPLATE="8.2-cli-alpine"
  make test IMAGE_TEMPLATE="8.2-fpm-alpine"
  make test IMAGE_TEMPLATE="8.2-supervisord-alpine"
  make test IMAGE_TEMPLATE="8.3-cli-alpine"
  make test IMAGE_TEMPLATE="8.3-fpm-alpine"
  make test IMAGE_TEMPLATE="8.3-supervisord-alpine"
  make test IMAGE_TEMPLATE="8.4-cli-alpine"
  make test IMAGE_TEMPLATE="8.4-fpm-alpine"
  make test IMAGE_TEMPLATE="8.4-supervisord-alpine"
  ```

### → Test Configuration

The test configurations are defined in `goss.yaml` files, which are generated for each image variant. These files specify the tests to be run, including:

- File existence and permissions
- Process checks
- Port availability
- Package installations
- Command outputs
- PHP extension availability

### → Test Process

When you run the `make test` command, the following steps occur:

1. The specified Docker image is built (if not already present).
2. dgoss runs the tests defined in the `goss.yaml` file against the Docker container.
3. The test results are displayed in the console.

<br>

## 🔒 Security Policy

This project has a [security policy](.github/SECURITY.md).

<br>

## 🙌 Want to Contribute?

Thank you for considering contributing to the wayofdev community! We are open to all kinds of contributions. If you want to:

- 🤔 [Suggest a feature](https://github.com/wayofdev/docker-php-dev/issues/new?assignees=&labels=type%3A+enhancement&projects=&template=2-feature-request.yml&title=%5BFeature%5D%3A+)
- 🐛 [Report an issue](https://github.com/wayofdev/docker-php-dev/issues/new?assignees=&labels=type%3A+documentation%2Ctype%3A+maintenance&projects=&template=1-bug-report.yml&title=%5BBug%5D%3A+)
- 📖 [Improve documentation](https://github.com/wayofdev/docker-php-dev/issues/new?assignees=&labels=type%3A+documentation%2Ctype%3A+maintenance&projects=&template=4-docs-bug-report.yml&title=%5BDocs%5D%3A+)
- 👨‍💻 [Contribute to the code](./.github/CONTRIBUTING.md)

You are more than welcome. Before contributing, kindly check our [contribution guidelines](.github/CONTRIBUTING.md).

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg?style=for-the-badge)](https://conventionalcommits.org)

<br>

## 🫡 Contributors

<p align="left">
<a href="https://github.com/wayofdev/docker-php-dev/graphs/contributors">
<img align="left" src="https://img.shields.io/github/contributors-anon/wayofdev/docker-php-dev?style=for-the-badge" alt="Contributors Badge"/>
</a>
<br>
<br>
</p>

## 🌐 Social Links

- **Twitter:** Follow our organization [@wayofdev](https://twitter.com/intent/follow?screen_name=wayofdev) and the author [@wlotyp](https://twitter.com/intent/follow?screen_name=wlotyp).
- **Discord:** Join our community on [Discord](https://discord.gg/CE3TcCC5vr).

<br>

## ⚖️ License

[![Licence](https://img.shields.io/github/license/wayofdev/docker-php-dev?style=for-the-badge&color=blue)](./LICENSE.md)

<br>
