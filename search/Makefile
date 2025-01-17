IMAGE := 981935913893.dkr.ecr.us-west-2.amazonaws.com/amundsen-staging-search
VERSION:= $(shell grep -m 1 '__version__' setup.py | cut -d '=' -f 2 | tr -d "'" | tr -d '[:space:]')
OIDC_IMAGE := ${IMAGE}-oidc
.PHONY: test
clean:
	find . -name \*.pyc -delete
	find . -name __pycache__ -delete
	rm -rf dist/

.PHONY: test_unit
test_unit:
	python3 -bb -m pytest tests

.PHONY: lint
lint:
	flake8 .

.PHONY: mypy
mypy:
	mypy --ignore-missing-imports --strict-optional --warn-no-return .

.PHONY: isort
isort:
	isort .

.PHONY: isort_check
isort_check:
	isort ./ --check --diff

.PHONY: test
test: test_unit lint mypy isort_check

.PHONY: image
image:
	cd .. && docker build -f Dockerfile.search.public -t ${IMAGE}:latest . && cd search

.PHONY: image-version
image-version:
	cd .. && docker build -f Dockerfile.search.public -t ${IMAGE}:${VERSION} . && cd search

.PHONY: push-image-version
push-image-version:
	docker push ${IMAGE}:${VERSION}

.PHONY: push-image
push-image:
	aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 981935913893.dkr.ecr.us-west-2.amazonaws.com
	docker push ${IMAGE}:latest

.PHONY: build-push-image
build-push-image-latest: image push-image
build-push-image-version: image-version push-image-version

.PHONY: install_deps
install_deps:
	pip3 install -e ".[all]"

.PHONY: oidc-image
oidc-image:
	cd .. && docker build -f Dockerfile.search.public --target=oidc-release -t ${OIDC_IMAGE}:${VERSION} . && cd search
	docker tag ${OIDC_IMAGE}:${VERSION} ${OIDC_IMAGE}:latest


.PHONY: push-oidc-image
push-oidc-image:
	aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 981935913893.dkr.ecr.us-west-2.amazonaws.com
	docker push ${OIDC_IMAGE}:latest
	docker push ${OIDC_IMAGE}:${VERSION}
