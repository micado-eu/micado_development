#!/bin/bash

# Define the repositories to clone within micado_development
repos=(
    "https://github.com/micado-eu/backend"
    "https://github.com/micado-eu/migrant_application"
    "https://github.com/micado-eu/pa_application"
    "https://github.com/micado-eu/ngo_application"
)

# Define additional directories to create
additional_dirs=(
    "db_data"
    "weblate_data"
    "redis_data"
    "git_data"
    "portainer-data"
    "shared_images"
    "traefik-acme"
    "translations_dir"
)

# Loop through the repositories and clone each one within micado_development
for repo in "${repos[@]}"; do
    git clone "$repo"
done

# Create the additional directories within micado_development
for dir in "${additional_dirs[@]}"; do
    mkdir -p "$dir"
done

echo "All repositories have been cloned and additional directories created in micado_development."
