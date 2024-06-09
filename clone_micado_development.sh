#!/bin/bash

# URL of the micado_development repository
micado_development_repo="https://github.com/micado-eu/micado_development"

# Create a temporary directory
temp_dir=$(mktemp -d)

# Clone the micado_development repository into the temporary directory
git clone "$micado_development_repo" "$temp_dir"

# Move contents from the temporary directory to the current directory
mv "$temp_dir"/* "$temp_dir"/.[!.]* .

# Remove the temporary directory
rmdir "$temp_dir"

# Make setup_micado_repos.sh executable
chmod +x setup_micado_repos.sh

# Execute setup_micado_repos.sh
./setup_micado_repos.sh

echo "micado_development repository cloned, setup script executed, and additional repositories and directories set up."
