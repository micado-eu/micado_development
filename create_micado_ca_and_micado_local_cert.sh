#!/bin/bash

# Directories for CA
mkdir -p MicadoCA/newcerts
mkdir -p MicadoCA/private
mkdir -p MicadoCA/certs
mkdir -p traefik/certs
mkdir -p traefik/traefik-acme
touch MicadoCA/index.txt
echo 1000 > MicadoCA/serial

# Generate CA private key
openssl genpkey -algorithm RSA -out MicadoCA/private/ca.key -aes256 -pass pass:micadoca

# Create CA configuration file
cat > MicadoCA/ca.cnf <<EOL
[ ca ]
default_ca = CA_default

[ CA_default ]
dir = ./MicadoCA
certs = \$dir/certs
new_certs_dir = \$dir/newcerts
database = \$dir/index.txt
serial = \$dir/serial
RANDFILE = \$dir/private/.rand

private_key = \$dir/private/ca.key
certificate = \$dir/certs/ca.crt

default_days = 3650
default_md = sha256

policy = policy_strict

[ policy_strict ]
countryName = match
stateOrProvinceName = match
organizationName = match
organizationalUnitName = optional
commonName = supplied
emailAddress = optional

[ req ]
dir = ./MicadoCA
default_bits = 2048
default_md = sha256
default_keyfile = \$dir/private/ca.key
prompt = no
encrypt_key = yes

distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C = IT
ST = Torino
L = Torino
O = MICADO
OU = MICADO-Dev
CN = MicadoCA
EOL

# Generate CA certificate
openssl req -x509 -new -key MicadoCA/private/ca.key -sha256 -days 3650 -out MicadoCA/certs/ca.crt -config MicadoCA/ca.cnf -passin pass:micadoca

# Generate private key for micado.local certificate
openssl genpkey -algorithm RSA -out traefik/certs/micado.local.key

# Create micado.local certificate configuration file
cat > micado_local_cert.cnf <<EOL
[ req ]
default_bits        = 2048
default_md          = sha256
default_keyfile     = traefik/certs/micado.local.key
prompt              = no
encrypt_key         = no

distinguished_name  = req_distinguished_name
req_extensions      = req_ext

[ req_distinguished_name ]
C                   = IT
ST                  = Torino
L                   = Torino
O                   = MICADO
OU                  = MICADO-Dev
CN                  = *.micado.local

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = *.micado.local
DNS.2 = micado.local
EOL

# Generate CSR for micado.local certificate
openssl req -new -key traefik/certs/micado.local.key -out traefik/certs/micado.local.csr -config micado_local_cert.cnf

# Create CA signing configuration
cat > ca_signing.cnf <<EOL
[ ca ]
default_ca = CA_default

[ CA_default ]
dir = ./MicadoCA
certs = \$dir/certs
new_certs_dir = \$dir/newcerts
database = \$dir/index.txt
serial = \$dir/serial
RANDFILE = \$dir/private/.rand

private_key = \$dir/private/ca.key
certificate = \$dir/certs/ca.crt

default_days = 3650
default_md = sha256

policy = policy_strict

[ policy_strict ]
countryName = match
stateOrProvinceName = match
organizationName = match
organizationalUnitName = optional
commonName = supplied
emailAddress = optional
EOL

# Sign the micado.local certificate with the CA
openssl ca -config ca_signing.cnf -in traefik/certs/micado.local.csr -out traefik/certs/micado.local.crt -batch -extensions req_ext -extfile micado_local_cert.cnf -passin pass:micadoca
