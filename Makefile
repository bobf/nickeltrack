.PHONY: build
build:
	git archive master --format tar.gz -o .build/context.tar.gz
	docker-compose build application
	rm .build/context.tar.gz
