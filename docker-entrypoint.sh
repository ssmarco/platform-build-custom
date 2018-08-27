#!/usr/bin/env bash
set -e

source /funcs.sh

if [ -d ".git" ]; then
    SHA=$(git rev-parse HEAD)
else
    echo "Unable to determine SHA, failing."
    exit 1
fi

if [[ "z${IDENT_KEY}" == "z" ]]; then
    echo "No deploy key set"
else
    mkdir -p ~/.ssh
    echo "${IDENT_KEY}" > ~/.ssh/id_rsa
    chmod 0600 ~/.ssh/id_rsa
    echo "Using deploy key"
fi

composer_install

vendor_expose

# Run custom logic
./tools/pre-build-archive

package_source ${SHA}
