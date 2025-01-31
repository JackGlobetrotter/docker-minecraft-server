#! /bin/bash

VERSION=MASTER
GITHUB_PATH="https://github.com/JackGlobetrotter/docker-minecraft-server"

TARGET=$(dpkg --print-architecture)

mkdir -p /mnt/server
cd /mnt/server

set -euo pipefail

apt-get update

DEBIAN_FRONTEND=noninteractive \
apt-get install -y \
  wget \
  file \
  gosu \
  sudo \
  iputils-ping \
  curl \
  git \
  jq \
  dos2unix \
  mysql-client \
  unzip \
  zstd \
  lbzip2 \
  nfs-common \
  libpcap0.8

apt-get clean

wget  https://github.com/itzg/easy-add/releases/download/0.7.2/easy-add_linux_amd64 -O /usr/bin/easy-add
chmod +x /usr/bin/easy-add

easy-add --var os=linux --var arch=amd64  --var version=1.2.0 --var app=restify --file {{.app}}  --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz
easy-add --var os=linux --var arch=amd64  --var version=1.6.1 --var app=rcon-cli --file {{.app}}  --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz
easy-add --var os=linux --var arch=amd64  --var version=0.11.0 --var app=mc-monitor --file {{.app}}  --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz
easy-add --var os=linux --var arch=amd64  --var version=1.8.3 --var app=mc-server-runner --file {{.app}}  --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz
easy-add --var os=linux --var arch=amd64  --var version=0.1.1 --var app=maven-metadata-release --file {{.app}}  --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz

MC_HELPER_VERSION=1.27.9
MC_HELPER_BASE_URL=https://github.com/itzg/mc-image-helper/releases/download/$MC_HELPER_VERSION

curl -fsSL $MC_HELPER_BASE_URL/mc-image-helper-$MC_HELPER_VERSION.tgz  | tar -C /usr/share -zxf -  && ln -s /usr/share/mc-image-helper-$MC_HELPER_VERSION/bin/mc-image-helper /usr/bin

# Patched knockd
curl -fsSL -o /tmp/knock.tar.gz https://github.com/Metalcape/knock/releases/download/0.8.1/knock-0.8.1-$TARGET.tar.gz
tar -xf /tmp/knock.tar.gz -C /usr/local/ && rm /tmp/knock.tar.gz
ln -s /usr/local/sbin/knockd /usr/sbin/knockd
find /usr/lib -name 'libpcap.so.0.8' -execdir cp '{}' libpcap.so.1 \;

if [[ "${VERSION^^}" == "MASTER" ]]; then
    curl -fsSL -o /tmp/main.zip "$GITHUB_PATH/archive/master.zip"
else
    curl -fsSL -o /tmp/main.zip "$GITHUB_PATH/archive/refs/tags/$VERSION.zip" 
fi

unzip /tmp/main.zip -d /tmp/main && rm /tmp/main.zip

cd /tmp/main/docker-minecraft-server-${VERSION,,}

cp pterodactyl/init.sh /init.sh
chmod 775 /init.sh

cd scripts

sed -i 's/\/data/\/home\/container/g' start*

cp -r start* /

chmod 775 /start*

echo -e "Install finished"