.PHONY: setup

SHELL = bash

all: setup

setup:
	command -v pre-commit > /dev/null && pre-commit install

.env:
	cp .env.dev .env

dev: .env
	DOCKER_BUILDKIT=1 docker-compose build
	docker-compose run --rm legacy make build
	docker-compose run --rm api libretime-api migrate
	docker-compose up -d

.PHONY: VERSION
VERSION:
	tools/version.sh

changelog:
	tools/changelog.sh

.PHONY: tarball
tarball: VERSION
	$(MAKE) -C legacy build
	cd .. && tar -czf libretime-$(shell cat VERSION | tr -d [:blank:]).tar.gz \
		--owner=root --group=root \
		--exclude-vcs \
		--exclude .codespellignore \
		--exclude .git* \
		--exclude .pre-commit-config.yaml \
		--exclude dev_tools \
		--exclude jekyll.sh \
		--exclude legacy/vendor/phing \
		--exclude legacy/vendor/simplepie/simplepie/tests \
		libretime
	mv ../libretime-*.tar.gz .

# Only clean subdirs
clean:
	git clean -xdf */

docs-lint:
	vale sync
	vale docs

website:
	git clone git@github.com:libretime/website.git

website/node_modules: website
	yarn --cwd website install

docs-dev: website website/node_modules
	DOCS_PATH="../docs" yarn --cwd website start
