#!/bin/bash

# init
script_path=$(cd "$(dirname "$0")" && pwd)
data_path="$script_path/any-sync-dockercompose"

# install buildx
if docker buildx version >/dev/null 2>&1; then
  echo "buildx is installed"
else
  echo "buildx notfound, start install ..."
  DOCKER_CONFIG=${DOCKER_CONFIG:-/usr/local/lib/docker}
  sudo mkdir -p $DOCKER_CONFIG/cli-plugins

  DOCKER_BUILDX_VERSION=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | jq -r .tag_name)
  sudo curl -SL https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.$(uname -s)-$(uname -m | sed 's/x86_64/amd64/;s/armv6l/arm-v6/;s/armv7l/arm-v7/;s/aarch64/arm64/') -o $DOCKER_CONFIG/cli-plugins/docker-buildx

  if [ $? -ne 0 ]; then
    echo "install buildx error!"
    exit 1
  else
    echo "install buildx success!"
  fi
  sudo chmod +x $DOCKER_CONFIG/cli-plugins/docker-buildx
fi

# show buildx version
echo "docker buildx version"
docker buildx version

# clone any-sync-dockercompose
clone_finish="$data_path/clone_finish.txt"
if [ -f "$clone_finish" ]; then
  echo "any-sync-dockercompose is exist, continue!"
else
  clone_path="https://github.com/anyproto/any-sync-dockercompose.git"
  rm -rf "$data_path"
  echo "clone any-sync-dockercompose: $clone_path"
  git clone "$clone_path" "$data_path"
  if [ $? -ne 0 ]; then
    echo "clone error!"
    exit 1
  else
    touch "$clone_finish"
    echo "clone success!"
  fi
fi

# # git pull
# echo "git pull..."
# cd "$data_path"
# git pull
# if [ $? -ne 0 ]; then
#   echo "git pull error!"
#   exit 1
# else
#   touch "$clone_finish"
#   echo "git pull success!"
# fi

# mkdir
echo "mkdir..."
mkdir -p "$data_path/storage/minio"
mkdir -p "$data_path/storage/redis"
mkdir -p "$data_path/storage/mongo-1"
mkdir -p "$data_path/storage/networkStore/any-sync-coordinator"
mkdir -p "$data_path/storage/any-sync-node-1"
mkdir -p "$data_path/storage/any-sync-node-2"
mkdir -p "$data_path/storage/any-sync-node-3"
mkdir -p "$data_path/storage/networkStore/any-sync-node-1"
mkdir -p "$data_path/storage/networkStore/any-sync-node-2"
mkdir -p "$data_path/storage/networkStore/any-sync-node-3"
mkdir -p "$data_path/storage/networkStore/any-sync-consensusnode"
mkdir -p "$data_path/storage/networkStore/any-sync-filenode"
echo "mkdir success!"

# rewrite .env.override
echo "rewrite .env.override"
cd "$data_path"
cp -f "$script_path/.env.override" "$data_path/.env.override"

# build generateconfig image
echo "docker buildx..."
cd "$data_path"
docker buildx build --tag generateconfig-env --file Dockerfile-generateconfig-env .
if [ $? -ne 0 ]; then
  echo "docker buildx error!"
  exit 1
else
  echo "docker buildx success!"
fi

# run docker generateconfig-env
echo "docker generateconfig-env..."
docker run --rm --volume ${data_path}/:/code/ -e HTTP_PROXY=$HTTP_PROXY -e HTTPS_PROXY=$HTTPS_PROXY generateconfig-env
if [ $? -ne 0 ]; then
  echo "docker generateconfig-env error!"
  exit 1
else
  echo "docker generateconfig-env success!"
fi

echo "docker compose pull..."
sed -i '/^RUN go/i ENV GOPROXY=https://goproxy.cn' Dockerfile-generateconfig-anyconf
docker compose pull
if [ $? -ne 0 ]; then
  echo "docker compose pull error!"
  exit 1
else
  echo "docker compose pull success!"
fi
