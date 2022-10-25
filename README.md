# About

Flipper Zero FW report analyzer frontend

# Requirements

Docker or node.js

# Development

- `make install` - to install node.js modules
- `make run` - to start node.js development server
- `make build` - to build site dist
- `make preview` - to build site dist and start preview server
- `make docker` - build `firmware_report_client` and tag with `latest`
- `make docker_nginx` - build docker image and start nginx service

# Testing

`curl -v http://127.0.0.1:80`

# Production

- `make docker` - build `firmware_report_client` and tag with `latest`
- Upload to container docker repository