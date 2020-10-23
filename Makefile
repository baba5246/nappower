IMAGE_NAME = nappower
PROJECT := $(shell gcloud config list --format 'value(core.project)' 2>/dev/null)
KEY_FILE = --keyfile=certs/server.key
CERT_FILE = --certfile=certs/cert.pem

.PHONY: all
all: help

.PHONY: build ## Build docker image
build:
	docker build -t $(IMAGE_NAME) .

.PHONY: run ## Run on local with PORT
run:
	docker run -it -e PORT=$(PORT) -p $(PORT):$(PORT) $(IMAGE_NAME)

.PHONY: deploy-prod ## Deploy to Cloud Run with 'prod' tag
deploy-prod:
	gcloud builds submit --tag gcr.io/$(PROJECT)/$(IMAGE_NAME):prod --project $(PROJECT)
	gcloud run deploy --image gcr.io/$(PROJECT)/$(IMAGE_NAME):prod --platform managed

.PHONY: deploy-dev ## Deploy to Cloud Run with 'dev' tag
deploy-dev:
	gcloud builds submit --tag gcr.io/$(PROJECT)/$(IMAGE_NAME):dev --project $(PROJECT)
	gcloud run deploy $(IMAGE_NAME) --region asia-northeast1 --image gcr.io/$(PROJECT)/$(IMAGE_NAME):dev --platform managed

.PHONY: help ## View help
help:
	@grep -E '^.PHONY: [a-zA-Z_-]+.*?## .*$$' $(MAKEFILE_LIST) | sed 's/^.PHONY: //g' | awk 'BEGIN {FS = "## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
