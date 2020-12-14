#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base_dir="${DIR}/.."

display() {
  echo "basedir is $base_dir"
}
