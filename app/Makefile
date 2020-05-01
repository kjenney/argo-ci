TAG = celfring/hello-world
build:
	docker build -t $(TAG) --rm .

push: build
	docker push $(TAG)

run:
	docker run --rm -p 8080:8080 -e PORT=8080 -v `pwd`:/app $(TAG)
dev:
	docker run --rm -p 8080:8080 -e PORT=8080 -v `pwd`:/app $(TAG) npm run start:dev

test:
	docker run --rm $(TAG) npm test

shell:
	docker run --rm -it -p 8080:8080 -e PORT=8080 -v `pwd`:/app $(TAG) sh

.PHONY: build run test push shell dev
