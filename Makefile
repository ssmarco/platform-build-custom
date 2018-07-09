all:
	docker build . -t silverstripe/platform-build-custom:latest

push:
    docker push silverstripe/platform-build-custom:latest