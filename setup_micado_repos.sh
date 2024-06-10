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

# Define the entries to be added to /etc/hosts
HOSTS_ENTRIES=$(cat <<EOF
# Micado Development Hostnames
127.0.0.1 migrant.micado.local
127.0.0.1 micado-pa.micado.local
127.0.0.1 ngo.micado.local
127.0.0.1 api.micado.local
127.0.0.1 gateway.micado.local
127.0.0.1 dashboard.micado.local
127.0.0.1 admin.micado.local
127.0.0.1 identity.micado.local
127.0.0.1 monitoring.micado.local
127.0.0.1 translate.micado.local
127.0.0.1 git.micado.local
127.0.0.1 portainer.micado.local
127.0.0.1 admin2.micado.local
127.0.0.1 multichatbot
127.0.0.1 traefik.micado.local
EOF
)

# Append the entries to /etc/hosts
echo "$HOSTS_ENTRIES" | sudo tee -a /etc/hosts > /dev/null

echo "Entries added to /etc/hosts successfully."

