#! /bin/bash

export TYPE=VANILLA 
export VERSION=LATEST 
export EULA=""

for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

echo ${TYPE}
# UID=1000 GID=1000

exec "${SCRIPTS:-/}start"