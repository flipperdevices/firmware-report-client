# Short cuts for common operations

.PHONY: run
run:
	npm run dev --prefix ./app

.PHONY: install
install:
	npm install --prefix ./app

.PHONY: build
build:
	npm run build --prefix ./app

.PHONY: preview
preview:
	npm run preview --prefix ./app

.PHONY: clean
clean:
	rm -rf ./app/node_modules && rm -rf ./app/dist

.PHONY: docker
docker:
	docker build . --tag "firmware-report-client:latest"

.PHONY: docker_nginx
docker_nginx: docker
	docker run -it -p 80:80 --rm "firmware-report-client:latest" 
