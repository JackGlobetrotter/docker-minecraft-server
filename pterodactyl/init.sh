#! /bin/bash

export TYPE=VANILLA 
export VERSION=LATEST 
export EULA=""

for ARGUMENT in (${STARTUP})
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

# UID=1000 GID=1000

echo "Starting from custom script"

exec "start"