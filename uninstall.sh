#!/bin/bash

# init
script_path=$(cd "$(dirname "$0")" && pwd)
data_path="$script_path/any-sync-dockercompose"

if [ -d "$data_path" ]; then
  echo "docker compose down"
  cd "$data_path"
  sudo docker compose down
  if [ $? -ne 0 ]; then
    echo "docker compose down error!"
    exit 1
  else
    echo "docker compose down success!"
  fi
  echo "clear docker space..."
  sudo docker system prune --all --volumes
  if [ $? -ne 0 ]; then
    echo "clear docker space error!"
    exit 1
  else
    echo "clear docker space success!"
  fi

  echo "rm $data_path ..."
  cd "$script_path"
  rm -rf "$data_path"

  echo "uninstall success!"
else
  echo "no install"
fi
