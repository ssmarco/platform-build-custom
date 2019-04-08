all:
	docker build . -t silverstripe/platform-build-aa:latest

push:
	docker push silverstripe/platform-build-aa
