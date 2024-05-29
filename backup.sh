#!/bin/bash

# init
script_path=$(cd "$(dirname "$0")" && pwd)
data_path="$script_path/any-sync-dockercompose"

if [ -d "$data_path" ]; then
  date_str=$(date +%Y_%m_%d)
  backup_zip="$script_path/${date_str}.zip"
  backup_dir="$script_path/backup"

  # copy
  echo "copy data..."
  cd "$script_path"
  mkdir -p "$backup_dir"

  cp -r "$data_path/etc" "$backup_dir/etc"
  cp -r "$data_path/storage" "$backup_dir/storage"

  # zip
  echo "zip data..."
  zip -r "$backup_zip" "./backup"

  if [ $? -eq 0 ]; then
    echo "backup success: $backup_zip"
    rm -rf "$backup_dir"
  else
    echo "backup error"
    exit 1
  fi
else
  echo "no install"
fi
