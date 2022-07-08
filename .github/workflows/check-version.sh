#!/usr/bin/env bash

BASE_DIR=$(cd $(dirname $BASH_SOURCE) && pwd)
LATEST_VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)
VERSION=$(cat $BASE_DIR/../../.chromedriver-version)

if [ "$LATEST_VERSION" != "$VERSION" ]; then
  echo "VERSION is $VERSION"
  echo "LATEST_VERSION is $LATEST_VERSION"
  echo "chromedriver version is outdated."
  exit 1
else
  echo "chromedriver is up to date!"
  exit 0
fi
