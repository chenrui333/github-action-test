#!/bin/bash

export DATE=`date -u +%Y%m%d%H%M`

echo RELEASE: $RELEASE
echo ENV: $ENVIRONMENT
echo USER: $USER
echo DATE: $DATE

set -e

template() {
    export TAG=$RELEASE
    envsubst < .github/workflows/scripts/test.tpl
}

main() {
    TEMPLATE=$(template)
}

time main
