# Short cuts for common operations

.PHONY: install
install:
	npm install --prefix ./app

.PHONY: run
run: install
	npm run dev --prefix ./app

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
	docker run -it -p 5173:80 --rm -e FW_BACKEND_URL=${FW_BACKEND_URL} "firmware-report-client:latest" 
