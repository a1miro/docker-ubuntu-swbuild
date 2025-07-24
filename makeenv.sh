#!/bin/bash

# This shell script creates .env environment which contains a list of the host users, 
# adding the username, usergroup, UID and GID in the user_list variable. 
# The host docker group GID is also added to the .env file. The .env file is 
# automatically sourced by docker compose during container build.

# Another file docker_entrypoint.sh is created. This is the entrypoint for the docker container.
# It checks if the home directory for each user exists in the current home directories volume, 
# and if not, it creates the home directory and copies the contents of /etc/skel. The generated script 
# is copied to the container and executed as the Docker entrypoint script.


# Creating user_list from existing users in /home folder of the host system
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

# Retrive the docker group GID
docker_gid="$(getent group docker | cut -d: -f3 2>/dev/null)"

# Create .env file
echo "user_list=\"${user_list}\"" >.env
echo "docker_gid=${docker_gid}" >>.env

# Create docker_entrypoint.sh script
echo "user_list=\"${user_list}\"" > docker_entrypoint.sh
echo "IFS=','" >> docker_entrypoint.sh
echo 'for entry in ${user_list}; do' >> docker_entrypoint.sh
echo "    uname=\$(echo \$entry | cut -d: -f1)" >> docker_entrypoint.sh
echo "    uid=\$(echo \$entry | cut -d: -f3)" >> docker_entrypoint.sh
echo "    home_dir=\$(getent passwd \"\$uname\" | cut -d: -f6)" >> docker_entrypoint.sh
echo "    if [ -n \"\$home_dir\" ] && [ ! -d \"\$home_dir\" ]; then" >> docker_entrypoint.sh
echo "        mkdir -p \"\$home_dir\"" >> docker_entrypoint.sh
echo "        cp -rT /etc/skel \"\$home_dir\"" >> docker_entrypoint.sh
echo "        chown -R \"\$uname\":\"\$uname\" \"\$home_dir\"" >> docker_entrypoint.sh
echo "        echo \"Created home for \$uname at \$home_dir\"" >> docker_entrypoint.sh
echo "    fi" >> docker_entrypoint.sh
echo "done" >> docker_entrypoint.sh

# Make the script executable
chmod +x docker_entrypoint.sh

echo "Success: Docker environment file .env and docker_entrypoint.sh are created"
