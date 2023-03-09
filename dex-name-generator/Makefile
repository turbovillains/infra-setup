IMAGE_NAME=secretgenerator
IMAGE_TAG=latest

CLIENT_NAME=test-app

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

generate:
	@echo "USAGE: make generate CLIENT_NAME=my-name"
	@docker run -it --rm $(IMAGE_NAME):$(IMAGE_TAG) $(CLIENT_NAME)
