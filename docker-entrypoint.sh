#!/usr/bin/env bash
set -e

cat ~/.ssh/known_hosts

if [ -d ".git" ]; then
    SHA=$(git rev-parse HEAD)
else
    echo "Unable to determine SHA, failing."
    exit 1
fi

if [ ! -z "$@" ]; then
    exec "$@"
fi

if [[ "z${IDENT_KEY}" == "z" ]]; then
    echo "No deploy key set"
else
    mkdir -p ~/.ssh
    echo "${IDENT_KEY}" > ~/.ssh/id_rsa
    chmod 0600 ~/.ssh/id_rsa
    echo "Using deploy key"
fi

export COMPOSER_PROCESS_TIMEOUT=1200

if [ -f "composer.json" ]; then
    echo composer validate
    composer validate || true

    echo composer install --no-progress --no-scripts --prefer-dist --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-suggest
    composer install \
        --no-progress \
        --no-scripts \
        --prefer-dist \
        --no-dev \
        --ignore-platform-reqs \
        --optimize-autoloader \
        --no-interaction \
        --no-suggest
else
    echo "No composer.json present, skipping composer install."
fi

# Now that composer has ran, we can test for ss4
if [ ! -d "vendor/silverstripe/vendor-plugin" ]; then
    echo "SilverStripe 3 detected. Skipping module exposure."

    # Run custom logic
    ./tools/pre-build-archive

    # manifest expects tar to uncompress to a folder called site - required for bc
    cd ../
    mkdir -p site
    # working dir looks like this on live "payload-source-a80a63b8223e30248e204f1fa9cbac13c8738b3f.zip"
    RESULT="0"
    cp -rp payload-source-"$SHA".zip/. site || RESULT="$?"
    if [ "$RESULT" -ne "0" ]; then
        # locally the working dir is app
        cp -rp app/. site
    fi
    tar -czf /payload-source-"$SHA".tgz site
    exit 0
fi

echo "SilverStripe 4 detected. Running 'composer vendor-expose'."

# This is the preferred method of exposing the resources in SS4.
echo composer vendor-expose copy
RETVAL="0"
composer vendor-expose copy || RETVAL=$?

if [ "$RETVAL" -gt "0" ]; then
    echo "[WARNING] 'composer vendor-expose' failed. Falling back to vendor-plugin-helper." >&2
    /tmp/vendor/bin/vendor-plugin-helper copy ./
fi

# Run custom logic
./tools/pre-build-archive

# Remove git repository
rm -rf .git/

# manifest expects tar to uncompress to a folder called site - required for bc
cd ../
mkdir -p site
# working dir looks like this on live "payload-source-a80a63b8223e30248e204f1fa9cbac13c8738b3f.zip"
RESULT="0"
cp -rp payload-source-"$SHA".zip/. site || RESULT="$?"
if [ "$RESULT" -ne "0" ]; then
    # locally the working dir is app
    cp -rp app/. site
fi
tar -czf /payload-source-"$SHA".tgz site
