VERSION?=$$(git rev-parse --abbrev-ref HEAD)

.PHONY: all
all: dockerize

.PHONY: bump
bump: bump-requirements

poetry.lock:
	poetry install

requirements.txt: poetry.lock
	poetry export -o $@

requirements_development.txt: poetry.lock
	poetry export --dev -o $@

.PHONY: bump-poetry-lock
bump-poetry-lock:
	poetry update

.PHONY: clean-requirements
clean-requirements:
	rm -rf requirements.txt requirements_development.txt

.PHONY: bump-requirements
bump-requirements: bump-poetry-lock clean-requirements requirements.txt requirements_development.txt

.PHONY: dockerize
dockerize:
	docker build --tag kdsnice/marge-bot:$$(cat version) .

.PHONY: docker-push
docker-push:
	if [ -n "$$DOCKER_USERNAME" -a -n "$$DOCKER_PASSWORD" ]; then \
		docker login -u "$${DOCKER_USERNAME}" -p "$${DOCKER_PASSWORD}"; \
	else \
		docker login; \
	fi
	docker tag kdsnice/marge-bot:$$(cat version) kdsnice/marge-bot:$(VERSION)
	if [ "$(VERSION)" = "$$(cat version)" ]; then \
		docker tag kdsnice/marge-bot:$$(cat version) kdsnice/marge-bot:latest; \
		docker tag kdsnice/marge-bot:$$(cat version) kdsnice/marge-bot:stable; \
		docker push kdsnice/marge-bot:stable; \
		docker push kdsnice/marge-bot:latest; \
	fi
	docker push kdsnice/marge-bot:$(VERSION)
