# Micado Development

This repository contains the necessary components for setting up and developing the Micado project. The repository includes scripts for cloning additional repositories and creating required directories for development.

## Repository Structure

```
micado_development/
├── clone_micado_development.sh
├── setup_micado_repos.sh
├── .env
└── docker-compose.yaml
```

- **clone_micado_development.sh**: Script to clone the micado_development repository and execute the setup script.
- **setup_micado_repos.sh**: Script to clone additional repositories and create required directories.
- **.env**: Environment variables file for Docker Compose.
- **docker-compose.yaml**: Docker Compose configuration file.

## Setup Instructions

To set up the development environment, follow these steps:

### Execute the development environment creation script

Download and execute the `clone_micado_development.sh` script to clone the `micado_development` repository:

```bash
wget --no-cache https://raw.githubusercontent.com/micado-eu/micado_development/main/clone_micado_development.sh
chmod +x clone_micado_development.sh
./clone_micado_development.sh
```

This script will:
1. Clone the `micado_development` repository.
2. Change into the `micado_development` directory.
3. Make the `setup_micado_repos.sh` script executable.
4. Execute the `setup_micado_repos.sh` script to set up additional repositories and directories.

The `setup_micado_repos.sh` script will:
1. Clone the following repositories:
    - [backend](https://github.com/micado-eu/backend)
    - [migrant_application](https://github.com/micado-eu/migrant_application)
    - [pa_application](https://github.com/micado-eu/pa_application)
    - [ngo_application](https://github.com/micado-eu/ngo_application)
2. Create the necessary directories for development.

At the end, the resulting folder structure will be:
```
micado_development/
├── backend/
├── db_data/
├── git_data/
├── migrant_application/
├── ngo_application/
├── pa_application/
├── portainer-data/
├── redis_data/
├── shared_images/
├── traefik-acme/
├── translations_dir/
├── weblate_data/
├── clone_micado_development.sh
├── setup_micado_repos.sh
├── .env
└── docker-compose.yaml
```

- **backend/**: Cloned repository containing the backend code.
- **db_data/**: Directory for database data.
- **git_data/**: Directory for Git-related data.
- **migrant_application/**: Cloned repository containing the migrant application code.
- **ngo_application/**: Cloned repository containing the NGO application code.
- **pa_application/**: Cloned repository containing the PA application code.
- **portainer-data/**: Directory for Portainer data.
- **redis_data/**: Directory for Redis data.
- **shared_images/**: Directory for shared images.
- **traefik-acme/**: Directory for Traefik ACME data.
- **translations_dir/**: Directory for translation files.
- **weblate_data/**: Directory for Weblate data.
- **clone_micado_development.sh**: Script to clone the micado_development repository and execute the setup script.
- **setup_micado_repos.sh**: Script to clone additional repositories and create required directories.
- **.env**: Environment variables file for Docker Compose.
- **docker-compose.yaml**: Docker Compose configuration file.

## Environment Variables

The `.env` file contains environment variables used by Docker Compose. Below is an example of the `.env` file:

```
# .env file
POSTGRES_USER=micado_user
POSTGRES_PASSWORD=micado_pass
POSTGRES_DB=micado_db
KEYCLOAK_USER=admin
KEYCLOAK_PASSWORD=admin
PGROONGA_IMAGE_TAG=latest
KEYCLOAK_IMAGE_TAG=latest
NGINX_IMAGE_TAG=latest
TRAEFIK_IMAGE_TAG=latest
GITEA_IMAGE_TAG=latest
WEBLATE_IMAGE_TAG=latest
REDIS_IMAGE_TAG=latest
PORTAINER_IMAGE_TAG=latest
MIGRANTS_IMAGE_TAG=latest
PA_IMAGE_TAG=latest
API_HOSTNAME=api.micado.local
IDENTITY_HOSTNAME=identity.micado.local
MIGRANTS_HOSTNAME=migrants.micado.local
PA_HOSTNAME=pa.micado.local
NGO_HOSTNAME=ngo.micado.local
MICADO_API_KEY=your_api_key
IDENTITY_SP_MIGRANTS_CLIENT_ID=migrants_client_id
IDENTITY_SP_PA_CLIENT_ID=pa_client_id
IDENTITY_SP_NGO_CLIENT_ID=ngo_client_id
TRAEFIK_HOSTNAME=traefik.micado.local
TRAEFIK_ACME_EMAIL=your_email@example.com
TRAEFIK_LOG_LEVEL=DEBUG
MICADO_BACKEND_IMAGE_TAG=latest
GIT_HOSTNAME=git.micado.local
WEBLATE_SERVER_EMAIL=weblate@example.com
WEBLATE_DEFAULT_FROM_EMAIL=weblate@example.com
WEBLATE_ALLOWED_HOSTS=weblate.micado.local
WEBLATE_ADMIN_PASSWORD=admin
WEBLATE_ADMIN_NAME=admin
WEBLATE_ADMIN_EMAIL=admin@example.com
TRANSLATION_HOSTNAME=translation.micado.local
WEBLATE_REGISTRATION_OPEN=true
WEBLATE_POSTGRES_PASSWORD=postgres
WEBLATE_POSTGRES_USER=postgres
WEBLATE_POSTGRES_HOST=micado_db
POSTGRES_PORT=5432
TZ=Europe/Berlin
```

## Docker Compose

The `docker-compose.yaml` file defines the Docker services for the Micado project. Below is an overview of the `docker-compose.yaml` file:

```yaml
version: "3.9"
x-generic: &generic
  networks:
    - micado_dev_net
  logging:
    options:
      max-size: "12m"
      max-file: "5"
    driver: json-file

services:
  # DATABASE STUFF
  micado_db:
    image: groonga/pgroonga:${PGROONGA_IMAGE_TAG}
    env_file:
      - .env
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - type: volume
        source: postgres_data
        target: /var/lib/postgresql/data
      - type: volume
        source: postgres_init
        target: /docker-entrypoint-initdb.d
    healthcheck:
      test: [ "CMD-SHELL", "pg_isready -d $${POSTGRES_DB} -U $${POSTGRES_USER}" ]
      interval: 10s
      timeout: 5s
      retries: 5
    <<: *generic

  # Identity management
  keycloak:
    image: quay.io/keycloak/keycloak:${KEYCLOAK_IMAGE_TAG}
    command: ["start-dev", "--import-realm"]
    environment:
      KC_DB: postgres
      KC_DB_USERNAME: ${KEYCLOAK_DB_USER}
      KC_DB_PASSWORD: ${POSTGRES_PASSWORD}
      KC_DB_URL: "jdbc:postgresql://micado_db:5432/${POSTGRES_DB}"
      KC_DB_SCHEMA: ${KEYCLOAK_DB_SCHEMA}
      KC_METRICS_ENABLED: true
      KC_LOG_LEVEL: ${KC_LOG_LEVEL}
      KC_REALM_NAME: ${KC_REALM_NAME}
      KEYCLOAK_ADMIN: ${KEYCLOAK_ADMIN}
      KEYCLOAK_ADMIN_PASSWORD: ${KEYCLOAK_ADMIN_PASSWORD}
      KC_HOSTNAME: ${IDENTITY_HOSTNAME}
    healthcheck:
      test: timeout 10s bash -c ':> /dev/tcp/127.0.0.1/8080' || exit 1
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 90s
    depends_on:
      micado_db:
        condition: service_healthy
    <<: *generic

  # Web components
  traefik:              # LOAD BALANCER
    image: traefik:${TRAEFIK_IMAGE_TAG}
    command:
      - "--log.level=${TRAEFIK_LOG_LEVEL}"
      - "--accesslog=true"
      - "--api.dashboard=true"
      - "--api.insecure=true"
      - "--ping=true"
      - "--ping.entrypoint=ping"
      - "--entryPoints.ping.address=:8082"
      - "--entryPoints.web.address=:80"
      - "--entryPoints.websecure.address=:443"
      - "--providers.docker=true"
      - "--providers.docker.endpoint=unix:///var/run/docker.sock"
      - "--providers.docker.exposedByDefault=false"
      - "--providers.file.directory=/configuration/conf"
      - "--providers.file.watch=true"
      - "--certificatesresolvers.letsencrypt.acme.tlschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.email=${TRAEFIK_ACME_EMAIL}"
      - "--certificatesresolvers.letsencrypt.acme.storage=/etc/traefik/acme/acme.json"
      - "--global.checkNewVersion=true"
      - "--global.sendAnonymousUsage=false"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik/:/configuration/
      - traefik-certificates:/etc/traefik/acme
    ports:
      - "80:80"
      - "443:443"
    healthcheck:
      test: traefik healthcheck --ping
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 5s
    environment:
      TRAEFIK_HOSTNAME: ${TRAEFIK_HOSTNAME}
    labels:
      traefik.enable: "true"
      traefik.http.routers.dashboard.rule: Host(`${TRAEFIK_HOSTNAME}`)
      traefik.http.routers.dashboard.service: api@internal
      traefik.http.routers.dashboard.entrypoints: web,websecure
      traefik.http.services.dashboard.loadbalancer.server.port: 8080
      docker_compose_diagram.cluster: Load Balancer
      docker_compose_diagram.icon: "diagrams.onprem.network.Traefik"
    <<: *generic


  data_migrants:
    env_file:
      - .env
    environment:
      MICADO_API_KEY: ${MICADO_API_KEY}
      API_HOSTNAME: ${API_HOSTNAME}
      ANALYTIC_HOSTNAME: ${ANALYTIC_HOSTNAME}
      IDENTITY_HOSTNAME: ${IDENTITY_HOSTNAME}
      IDENTITY_SP_MIGRANTS_CLIENT_ID: ${IDENTITY_SP_MIGRANTS_CLIENT_ID}
      MIGRANTS_HOSTNAME: ${MIGRANTS_HOSTNAME}
      ROCKETCHAT_HOSTNAME: ${ROCKETCHAT_HOSTNAME}
      BOT_NAME: ${BOT_NAME}
    image: ghcr.io/micado-eu/quasar:2024
    stdin_open: true
    tty: true
    volumes:
      - type: volume
        source: migrants_app
        target: /code
    ports:
      - "8000:8000"
      - "8080:8080"
    command: /bin/sh -c "envsubst < src/statics/config.tmpl.json > src/statics/config.json && npm install && quasar dev -m pwa"
    labels:
      docker_compose_diagram.cluster: MICADO Frontend
      docker_compose_diagram.icon: "diagrams.programming.framework.Vue"
      traefik.enable: "true"
      traefik.http.routers.migrant.rule: Host(`${MIGRANTS_HOSTNAME}`)
      traefik.http.routers.migrant.entrypoints: web
      traefik.http.routers.migrant.service: migrant
      traefik.http.routers.migrant.middlewares: redirect-migrant
      traefik.http.middlewares.redirect-migrant.redirectscheme.permanent: "true"
      traefik.http.middlewares.redirect-migrant.redirectscheme.scheme: https
      traefik.http.services.migrant.loadbalancer.server.port: 8080
      traefik.http.routers.migrant2.rule: Host(`${MIGRANTS_HOSTNAME}`)
      traefik.http.routers.migrant2.entrypoints: websecure
      traefik.http.routers.migrant2.tls: "true"
      #traefik.http.routers.migrant2.tls.certresolver: letsencrypt
      traefik.http.routers.migrant2.service: migrant2
      traefik.http.services.migrant2.loadbalancer.server.port: 8080
    depends_on:
      micado_db:
        condition: service_healthy
        restart: true
      traefik:
        condition: service_healthy
        restart: true
    <<: *generic

  data_pa:
    env_file:
      - .env
    environment:
      MICADO_API_KEY: ${MICADO_API_KEY}
      API_HOSTNAME: ${API_HOSTNAME}
      ANALYTIC_HOSTNAME: ${ANALYTIC_HOSTNAME}
      IDENTITY_HOSTNAME: ${IDENTITY_HOSTNAME}
      COUNTLY_PA_APP_KEY: ${COUNTLY_PA_APP_KEY}
      IDENTITY_SP_PA_CLIENT_ID: ${IDENTITY_SP_PA_CLIENT_ID}
      PA_HOSTNAME: ${PA_HOSTNAME}
    image: ghcr.io/micado-eu/quasar:2024
    stdin_open: true
    tty: true
    volumes:
      - type: volume
        source: pa_app
        target: /code
    ports:
      - "8001:8000"
      - "8081:8080"
    command: /bin/sh -c "envsubst < src/statics/config.tmpl.json > src/statics/config.json && npm install && quasar dev -m pwa"
    labels:
      traefik.enable: "true"
      traefik.http.routers.pa.rule: Host(`${PA_HOSTNAME}`)
      traefik.http.routers.pa.entrypoints: web
      traefik.http.routers.pa.service: pa
      traefik.http.routers.pa.middlewares: redirect-pa
      traefik.http.middlewares.redirect-pa.redirectscheme.permanent: "true"
      traefik.http.middlewares.redirect-pa.redirectscheme.scheme: https
      traefik.http.services.pa.loadbalancer.server.port: 8080
      traefik.http.routers.pa2.rule: Host(`${PA_HOSTNAME}`)
      traefik.http.routers.pa2.entrypoints: websecure
      traefik.http.routers.pa2.tls: "true"
      #traefik.http.routers.pa2.tls.certresolver: letsencrypt
      traefik.http.routers.pa2.service: pa2
      traefik.http.services.pa2.loadbalancer.server.port: 8080
      docker_compose_diagram.cluster: MICADO Frontend
      docker_compose_diagram.icon: "diagrams.programming.framework.Vue"
    <<: *generic

  data_ngo:
    env_file:
      - .env
    environment:
      MICADO_API_KEY: ${MICADO_API_KEY}
      API_HOSTNAME: ${API_HOSTNAME}
      ANALYTIC_HOSTNAME: ${ANALYTIC_HOSTNAME}
      IDENTITY_HOSTNAME: ${IDENTITY_HOSTNAME}
      COUNTLY_NGO_APP_KEY: ${COUNTLY_NGO_APP_KEY}
      IDENTITY_SP_NGO_CLIENT_ID: ${IDENTITY_SP_NGO_CLIENT_ID}
      NGO_HOSTNAME: ${NGO_HOSTNAME}
    image: ghcr.io/micado-eu/quasar:2024
    stdin_open: true
    tty: true
    volumes:
      - type: volume
        source: migrants_app
        target: /code
    ports:
      - "8002:8000"
      - "8082:8080"
    command: /bin/sh -c "envsubst < src/statics/config.tmpl.json > src/statics/config.json && npm install && quasar dev -m pwa"
    labels:
      traefik.enable: "true"
      traefik.http.routers.ngo.rule: Host(`${NGO_HOSTNAME}`)
      traefik.http.routers.ngo.entrypoints: web
      traefik.http.routers.ngo.service: ngo
      traefik.http.routers.ngo.middlewares: redirect-ngo
      traefik.http.middlewares.redirect-ngo.redirectscheme.permanent: "true"
      traefik.http.middlewares.redirect-ngo.redirectscheme.scheme: https
      traefik.http.services.ngo.loadbalancer.server.port: 8080
      traefik.http.routers.ngo2.rule: Host(`${NGO_HOSTNAME}`)
      traefik.http.routers.ngo2.entrypoints: websecure
      traefik.http.routers.ngo2.tls: "true"
      #traefik.http.routers.ngo2.tls.certresolver: letsencrypt
      traefik.http.routers.ngo2.service: ngo2
      traefik.http.services.ngo2.loadbalancer.server.port: 8080
      docker_compose_diagram.cluster: MICADO Frontend
      docker_compose_diagram.icon: "diagrams.programming.framework.Vue"
    <<: *generic


  # BACKEND COMPONENTS
  backend:
    image: micadoproject/micado_backend:18.19.1
    stdin_open: true
    tty: true
    ports:
      - "3000:3000"
    command: /bin/sh -c "bash"
    env_file:
      - .env
    environment:
      HOST: backend
      MICADO_GIT_URL: ${MICADO_GIT_URL}
      ROCKETCHAT_HOSTNAME: ${ROCKETCHAT_HOSTNAME}
      ROCKETCHAT_ADMIN: ${ROCKETCHAT_ADMIN}
      ROCKETCHAT_ADMIN_PWD: ${ROCKETCHAT_ADMIN_PWD}
      MICADO_TRANSLATIONS_DIR: ${MICADO_TRANSLATIONS_DIR}
      POSTGRES_DB: ${POSTGRES_DB}
      MICADO_DB_PWD: ${MICADO_DB_PWD}
      MICADO_DB_USER: ${MICADO_DB_USER}
      MICADO_DB_SCHEMA: ${MICADO_DB_SCHEMA}
      MICADO_ENV: ${MICADO_ENV}
      IDENTITY_HOSTNAME: ${IDENTITY_HOSTNAME}
      WEBLATE_EMAIL_HOST: ${WEBLATE_EMAIL_HOST}
      WEBLATE_EMAIL_HOST_USER: ${WEBLATE_EMAIL_HOST_USER}
      WEBLATE_EMAIL_HOST_SSL: ${WEBLATE_EMAIL_HOST_SSL}
      WEBLATE_EMAIL_HOST_PASSWORD: ${WEBLATE_EMAIL_HOST_PASSWORD}
      ANALYTIC_HOSTNAME: ${ANALYTIC_HOSTNAME}
      ALGORITHM: ${ALGORITHM}
      SALT: ${SALT}
      KEY_LENGTH: ${KEY_LENGTH}
      BUFFER_0: ${BUFFER_0}
      BUFFER_1: ${BUFFER_1}
      ALGORITHM_PASSWORD: ${ALGORITHM_PASSWORD}
      MICADO_WEBLATE_KEY: ${MICADO_WEBLATE_KEY}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - type: volume
        source: shared_images
        target: /images
      - type: volume
        source: translations_dir
        target: ${MICADO_TRANSLATIONS_DIR}
      - type: volume
        source: backend
        target: /code
    labels:
      com.centurylinklabs.watchtower.enable: "false" 
      traefik.enable: "true"
      traefik.http.routers.backend.rule: Host(`${API_HOSTNAME}`)
      traefik.http.routers.backend.entrypoints: web
      traefik.http.routers.backend.middlewares: redirect-backend
      traefik.http.middlewares.redirect-backend.redirectscheme.permanent: "true"
      traefik.http.middlewares.redirect-backend.redirectscheme.scheme: https
      traefik.http.routers.backend.service: backend_service
      traefik.http.services.backend_service.loadbalancer.server.port: 3000
      traefik.http.routers.backend_https.rule: Host(`${API_HOSTNAME}`)
      traefik.http.routers.backend_https.entrypoints: websecure
      traefik.http.routers.backend_https.tls: "true"
      traefik.http.routers.backend_https.tls.certresolver: letsencrypt
      traefik.http.routers.backend_https.service: backend_service_https
      traefik.http.services.backend_service_https.loadbalancer.server.port: 3000
      traefik.http.services.backend_service_https.loadbalancer.server.scheme: http
      traefik.http.routers.backend_https.middlewares: backendcors
      traefik.http.middlewares.backendcors.headers.accesscontrolallowmethods: GET,OPTIONS,PUT
      traefik.http.middlewares.backendcors.headers.accesscontrolallowheaders: "*"
      traefik.http.middlewares.backendcors.headers.accesscontrolalloworiginlist: "*"
      traefik.http.middlewares.backendcors.headers.accesscontrolmaxage: 100
      traefik.http.middlewares.backendcors.headers.addvaryheader: "true"    
      docker_compose_diagram.cluster: MICADO Backend
      docker_compose_diagram.icon: "diagrams.programming.language.Nodejs"
    depends_on:
      micado_db:
        condition: service_healthy
        restart: true
    <<: *generic

  git:               # GIT SERVER
    image: gitea/gitea:${GITEA_IMAGE_TAG}
    <<: *generic
    environment:
      GIT_HOSTNAME: ${GIT_HOSTNAME}
      GITEA__database__DB_TYPE: postgres
      GITEA__database__HOST: micado_db:5432
      GITEA__database__NAME: ${POSTGRES_DB}
      GITEA__database__USER: ${GITEA_DB_USER}
      GITEA__database__PASSWD: ${GITEA_DB_PWD}
      GITEA__database__SCHEMA: ${GITEA_DB_SCHEMA}
      GITEA__sacurity__INSTALL_LOCK: "true"
      GITEA__service__DISABLE_REGISTRATION: "true"
    labels:
      com.centurylinklabs.watchtower.enable: "false" 
      traefik.enable: "true"
      traefik.http.routers.git1.rule: Host(`${GIT_HOSTNAME}`)
      traefik.http.routers.git1.entrypoints: web
      traefik.http.routers.git1.service: git1
      traefik.http.services.git1.loadbalancer.server.port: 3000
      traefik.http.routers.git2.rule: Host(`${GIT_HOSTNAME}`)
      traefik.http.routers.git2.entrypoints: websecure
      traefik.http.routers.git2.tls: "true"
      traefik.http.routers.git2.tls.certresolver: myresolver
      traefik.http.routers.git2.service: git2
      traefik.http.services.git2.loadbalancer.server.port: 3000
      docker_compose_diagram.cluster: Translation Platform
      docker_compose_diagram.icon: "diagrams.onprem.vcs.Gitea"
    volumes:
      - git_data:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    depends_on:
      micado_db:
        condition: service_healthy
        restart: true

  weblate:
    image: weblate/weblate:${WEBLATE_IMAGE_TAG}
    volumes:
      - weblate_data:/app/data
      - ./backend/weblate/0007_use_trigram.py:/usr/local/lib/python3.7/dist-packages/weblate/memory/migrations/0007_use_trigram.py
      - ./backend/weblate/0008_adjust_similarity.py:/usr/local/lib/python3.7/dist-packages/weblate/memory/migrations/0008_adjust_similarity.py
    environment:
      WEBLATE_EMAIL_HOST: ${WEBLATE_EMAIL_HOST}
      WEBLATE_EMAIL_HOST_USER: ${WEBLATE_EMAIL_HOST_USER}
      #      WEBLATE_EMAIL_HOST_PASSWORD: ${WEBLATE_EMAIL_HOST_PASSWORD}
      WEBLATE_SERVER_EMAIL: ${WEBLATE_SERVER_EMAIL}
      WEBLATE_DEFAULT_FROM_EMAIL: ${WEBLATE_DEFAULT_FROM_EMAIL}
      WEBLATE_ALLOWED_HOSTS: ${WEBLATE_ALLOWED_HOSTS}
      WEBLATE_ADMIN_PASSWORD: ${WEBLATE_ADMIN_PASSWORD}
      WEBLATE_ADMIN_NAME: ${WEBLATE_ADMIN_NAME}
      WEBLATE_ADMIN_EMAIL: ${WEBLATE_ADMIN_EMAIL}
      WEBLATE_SITE_TITLE: ${WEBLATE_SITE_TITLE}
      WEBLATE_SITE_DOMAIN: ${TRANSLATION_HOSTNAME}
      WEBLATE_REGISTRATION_OPEN: ${WEBLATE_REGISTRATION_OPEN}
      POSTGRES_PASSWORD: ${WEBLATE_POSTGRES_PASSWORD}
      POSTGRES_USER: ${WEBLATE_POSTGRES_USER}
      POSTGRES_DATABASE: ${POSTGRES_DB}
      POSTGRES_HOST: ${WEBLATE_POSTGRES_HOST}
      POSTGRES_PORT: ${POSTGRES_PORT}
      WEBLATE_WORKERS: 2
      WEBLATE_TIME_ZONE: ${TZ}
    labels:
      com.centurylinklabs.watchtower.enable: "false" 
      traefik.enable: "true"
      traefik.http.routers.weblate.rule: Host(`${TRANSLATION_HOSTNAME}`)
      traefik.http.routers.weblate.entrypoints: web
      #      - "traefik.http.routers.weblate.service=weblate"
      traefik.http.routers.weblate.middlewares: redirect-weblate
      traefik.http.middlewares.redirect-weblate.redirectscheme.scheme: https
      traefik.http.services.weblate.loadbalancer.server.port: 8080
      traefik.http.routers.weblate2.rule: Host(`${TRANSLATION_HOSTNAME}`)
      traefik.http.routers.weblate2.entrypoints: websecure
      traefik.http.routers.weblate2.tls: "true"
      traefik.http.routers.weblate2.tls.certresolver: letsencrypt
      traefik.http.routers.weblate2.service: weblate2
      traefik.http.services.weblate2.loadbalancer.server.port: 8080
      docker_compose_diagram.cluster: Translation Platform
      docker_compose_diagram.icon: "weblate.png"
    depends_on:
      micado_db:
        condition: service_healthy
        restart: true
      cache:
        condition: service_healthy
        restart: true
    <<: *generic

  cache:
    image: redis:${REDIS_IMAGE_TAG}
    command: ["redis-server", "--appendonly", "yes"]
    volumes:
      - redis_data:/data
    labels:
      docker_compose_diagram.cluster: Translation Platform
      docker_compose_diagram.icon: "diagrams.onprem.inmemory.Redis"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 5s
    <<: *generic

# ADMIN COMPONENTS
  portainer:
    image: portainer/portainer-ce:${PORTAINER_IMAGE_TAG}
    security_opt:
      - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./portainer-data:/data
    labels:
      com.centurylinklabs.watchtower.enable: "false" 
      traefik.enable: "true"
      traefik.http.routers.portainer.entrypoints: web
      traefik.http.routers.portainer.rule: Host(`${PORTAINER_HOSTNAME}`)
      traefik.http.middlewares.portainer-https-redirect.redirectscheme.scheme: https
      traefik.http.routers.portainer.middlewares: portainer-https-redirect
      traefik.http.routers.portainer-secure.entrypoints: websecure
      traefik.http.routers.portainer-secure.rule: Host(`${PORTAINER_HOSTNAME}`)
      traefik.http.routers.portainer-secure.tls: "true"
      traefik.http.routers.portainer-secure.tls.certresolver: myresolver
      traefik.http.routers.portainer-secure.service: portainer
      traefik.http.services.portainer.loadbalancer.server.port: "9000"
      docker_compose_diagram.cluster: Admin
      docker_compose_diagram.icon: "portainer.png"
    ports:
      - "9443:9443"
    <<: *generic



volumes:
  # in this development env we will use a local db_data so that we do not pollute the other db_data in the backend repo
  postgres_data:
    driver: local
    driver_opts:
      type: none
      device: $PWD/db_data
      o: bind
  # for the initialization data we use the data from the backend repo
  postgres_init:
    driver: local
    driver_opts:
      type: none
      device: $PWD/backend/db_init
      o: bind
  weblate_data:
    driver: local
    driver_opts:
      type: none
      device: $PWD/weblate_data
      o: bind
  redis_data:
    driver_opts:
      type: none
      device: $PWD/redis_data
      o: bind
  git_data:
    driver_opts:
      type: none
      device: $PWD/git_data
      o: bind
  portainer-data:
    driver: local
    driver_opts:
      type: none
      device: $PWD/portainer-data
      o: bind
  shared_images:
    driver: local
    driver_opts:
      type: none
      device: $PWD/shared_images
      o: bind
  translations_dir:
    driver_opts:
      type: none
      device: $PWD/translations_dir
      o: bind
  backend:
    driver: local
    driver_opts:
      type: none
      device: $PWD/backend/application
      o: bind
  migrants_app:
    driver: local
    driver_opts:
      type: none
      device: $PWD/migrant_application/app
      o: bind
  pa_app:
    driver: local
    driver_opts:
      type: none
      device: $PWD/pa_application/app
      o: bind
  ngo_app:
    driver: local
    driver_opts:
      type: none
      device: $PWD/ngo_application/app
      o: bind
  traefik-certificates:
    driver: local
    driver_opts:
      type: none
      device: $PWD/traefik/traefik-acme
      o: bind


networks:
  micado_dev_net:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.26.0.0/16
```

## Development strategy
This structure allows the developer to leverage on the folders of the existing MICADO's projects so that it will not be duplicated.
If there is the need to only develop the backend application the developer can use the docker-compose.yml file in the backend folder and work in it.
In case he needs to develop the integration between one frontend and the backend, the developer can use the docker-compose.yml file in this folder and work in it knowing that all the services will mount the code of the specific repo.  In this way any fix done will be in the source code of the specific repo and can be committed accordingly.

## Database Initialization

The will be initialized using the folder in the backend/db_init folder from the backend repo that is used as the authoritative source of the data.

## Clenaup

To cleanup the development environment since the docker containers create some folders with users different from the current owner, the following command is advised.

```
sudo rm -fr * .*
```

## Production differences
The production deployment has some differences that the developer must acknowledge: in production the Vue.JS applications will be stored as a distribution of javascript files in their own image and that content is copied in the NGINX container that will serve them.
For this reason in the production docker-compose there is also the NGINX service and the 3 services of the applications will only be the one that will copy the content of the javascript distribution into the NGINX; thus all the labels for the traefik balancer will be in the NGINX service instead.
Also in the development environment the 3 vue.js applications are exposed with their alias by Traefik and also directly with their ports, in this case the ports are:
8080 - migrant application
8081 - pa application
8082 - ngo application

## Contribution

Please submit pull requests or open issues to contribute to this repository.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```

Feel free to modify the URLs in the setup instructions and any other details as necessary to fit your actual setup and hosting environment.