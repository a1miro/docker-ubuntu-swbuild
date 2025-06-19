#!/bin/bash

# This script creates .env file for docker-compose and
# will consist of current user UID and GID, username,
# and some other variables

#uid="$(id -u)"
#gid="$(id -g)"
#username="$(id -u -n)"
#
#echo "uid=${uid}" >.env
#echo "gid=${gid}" >>.env
#echo "username=${username}" >>.env

user_list=""

for d in /home/*; do
  uname=$(basename "$d")
  uid=$(id -u "$uname" 2>/dev/null)
  gid=$(id -g "$uname" 2>/dev/null)
  gname=$(id -gn "$uname" 2>/dev/null)
  # Remove any spaces in the gname
  gname="${gname// /}" 
  if [ "$uid" -ge 1000 ] 2>/dev/null; then
    user_list+="$uname:$gname:$uid:$gid,"
  fi

done

docker_gid="$(getent group docker | cut -d: -f3 2>/dev/null)"

echo "user_list=\"${user_list}\"" >.env
echo "docker_gid=${docker_gid}" >>.env

echo "Success: Docker environment file .env is created"
