#!/bin/bash

# URL of the micado_development repository
micado_development_repo="https://github.com/micado-eu/micado_development"

# Clone the micado_development repository into the current directory
git clone "$micado_development_repo" .

# Make setup_micado_repos.sh executable
chmod +x setup_micado_repos.sh

# Execute setup_micado_repos.sh
./setup_micado_repos.sh

echo "micado_development repository cloned, setup script executed, and additional repositories and directories set up."
