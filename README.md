# Micado Development

This repository contains the necessary components for setting up and developing the Micado project. The repository includes scripts for cloning additional repositories and creating required directories for development.

## Repository Structure

```
micado_development/
├── clone_micado_development.sh
├── create_micado_ca_and_micado_local_cert.sh
├── setup_micado_repos.sh
├── .env
└── docker-compose.yaml
```

- **clone_micado_development.sh**: Script to clone the micado_development repository and execute the setup script.
- **create_micado_ca_and_micado_local_cert.sh**: Script to create a local CA certificate and a local certificate for the Micado project.
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
5. Make the `create_micado_ca_and_micado_local_cert.sh` script executable.
6. Execute the `create_micado_ca_and_micado_local_cert.sh` script to create a local CA certificate and a local certificate for the Micado project.

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

**ATTENTION**: The `setup_micado_repos.sh` script will clone the repositories from the master branch. If you want to clone a specific branch, you can modify the script accordingly or will have to clone the branches manually.

## Environment Variables

The [environment file](.env) file contains environment variables used by Docker Compose. You can customize these variables according to your needs.  In the file there are commensts for the variables that have to be customized.

## Docker Compose

The [docker compose](docker-compose.yaml) file defines the Docker services for the Micado project. 

### Docker Network Configuration

The Docker network configuration uses a bridge network named `micado_dev_net`:
This network allows the containers to communicate with each other using internal DNS, which resolves container names to their respective IP addresses within the network. This setup is crucial for the integrated services to interact seamlessly, such as the database service (`micado_db`), Keycloak for identity management, Traefik for reverse proxying, and other application services.

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

## Production Differences

### Development Environment

In the development environment, the Vue.js applications (migrant, pa, and ngo) are directly exposed by Traefik and are accessible on their respective ports:

- Migrant application: `8080`
- PA application: `8081`
- NGO application: `8082`

### Production Environment

In the production environment, the Vue.js applications are built and served as static files by an NGINX server. The Docker Compose configuration includes an NGINX service that serves the built JavaScript files. Consequently, the applications' services in the production setup primarily handle copying the static content into the NGINX container, and the Traefik configuration is adapted to route traffic through the NGINX service.

## Managing Keycloak
Keycloak import realms can be found in the `backend/keycloak/realms` folder.
If there is a need to modify a realm, the following command can be used from inside the container:

```
docker compose exec -it keycloak bash
/opt/keycloak/bin/kc.sh export --dir /tmp --users realm_file
```
This will generate a file named `X-realm.json` in the `/tmp` folder that can be copyed outside the container with the following command:

```
docker compose cp keycloak:/tmp/pa-realm.json pa-realm.json
```

## Contribution

Please submit pull requests or open issues to contribute to this repository.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```

Feel free to modify the URLs in the setup instructions and any other details as necessary to fit your actual setup and hosting environment.