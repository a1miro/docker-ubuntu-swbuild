#!/bin/bash

# This script creates .env file for docker-compose and
# will consist of current user UID and GID, username,
# and some other variables

uid="$(id -u)"
gid="$(id -g)"
username="$(id -u -n)"

pushd .. &> /dev/null
workspace="$(pwd)"
popd &> /dev/null


echo "uid=${uid}" >.env
echo "gid=${gid}" >>.env
echo "username=${username}" >>.env
echo "workspace=${workspace}" >>.env

echo "Success: Docker environment file .env is created"
