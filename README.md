# Platform Build Custom

Compacts a SilverStripe source code into a deployable state with composer

This image is different from [silverstripeltd/platform-build](https://github.com/silverstripeltd/platform-build) in that it calls a bash script `./tools/pre-build-archive` in the source code to do further processing, like gulp et cetera.


## What is this?

This is a docker container that runs three commands:

 - composer validate
 - composer install --no-progress --prefer-dist --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-suggest
 - The silverstripe [vendor plugin](https://github.com/silverstripe/vendor-plugin-helper) `vendor-plugin-helper copy ./`
 - and `./tools/pre-build-archive`

## Example usage

```
docker run \
    --interactive \
    --tty \
    --volume composer_cache:/tmp/cache \
    --volume ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro \
    --volume $PWD:/app \
    silverstripe/platform-build
```

`--volume composer_cache:/tmp/cache`

Creates a composer_cache volume if it doesn't exists and mounts that into the composer home folder `tmp`

`--volume ~/.ssh/id_rsa:/root/.ssh/id_rsa`

If your source code has private repositories, you will need to mount the private key (deploy key) into the container (preferable as read only)

`--volume $PWD:/app`

The source code will be build from the `/app` 'inside' the container, so make sure you mount source code into that
