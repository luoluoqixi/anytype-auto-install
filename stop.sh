#!/bin/bash

# init
script_path=$(cd "$(dirname "$0")" && pwd)
data_path="$script_path/any-sync-dockercompose"

if [ -d "$data_path" ]; then
  cd "$data_path"
  echo "stop..."
  sudo docker compose down
  if [ $? -ne 0 ]; then
    echo "stop error"
    exit 1
  else
    echo "stop success!"
  fi
else
  echo "no install"
fi
