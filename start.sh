#!/bin/bash

# init
script_path=$(cd "$(dirname "$0")" && pwd)
data_path="$script_path/any-sync-dockercompose"

if [ -d "$data_path" ]; then
  cd "$data_path"

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

  echo "starting..."
  docker compose up --detach --remove-orphans
  # docker compose up -d
  if [ $? -ne 0 ]; then
    echo "start error"
    exit 1
  else
    echo "start success!"
    echo "Done! Upload your self-hosted network configuration file ${data_path}/etc/client.yml into the client app"
    echo "See: https://doc.anytype.io/anytype-docs/data-and-security/self-hosting#switching-between-networks"
  fi
else
  echo "no install"
fi
