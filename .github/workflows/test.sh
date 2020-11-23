#!/bin/bash

export DATE=`date -u +%Y%m%d%H%M`

echo RELEASE: $RELEASE
echo ENV: $ENVIRONMENT
echo USER: $USER
echo DATE: $DATE

set -e

template() {
    export TAG=$RELEASE
    envtpl < .github/workflows/scripts/test.tpl
}

main() {
    TEMPLATE=$(template)

    cat $TEMPLATE
}

time main
