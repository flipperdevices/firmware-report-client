# About

Flipper Zero FW build report analyzer frontend

# Requirements

Docker or node.js

# Development

You need to set the FW_BACKEND_URL env variable to point to the backend server (eg FW_BACKEND_URL=127.0.0.1:5000).

- `make install` - to install node.js modules
- `make run` - to start node.js development server
- `make build` - to build site dist
- `make preview` - to build site dist and start preview server
- `make docker` - build `firmware-report-client` and tag with `latest`
- `make docker_nginx` - build docker image and start nginx service

# Testing

`curl -v http://127.0.0.1:5173`

# Production

- `make docker` - build `firmware-report-client` and tag with `latest`
- Upload to container docker repository
