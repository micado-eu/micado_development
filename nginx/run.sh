#!/bin/bash


echo "managing env variables"

env

envsubst '${MIGRANTS_HOSTNAME} ${PA_HOSTNAME} ${NGO_HOSTNAME} ${ANALYTIC_HOSTNAME} ${RASA_HOSTNAME}' < /usr/local/openresty/nginx/conf/nginx.conf.template > /usr/local/openresty/nginx/conf/nginx.conf

cat /usr/local/openresty/nginx/conf/nginx.conf 

echo "starting openresty"

/usr/bin/openresty
