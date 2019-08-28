IMAGE=docker.io/ironcladlou/ditm
CRI=docker

build-image:
	$(CRI) build -t $(IMAGE) .
.PHONY: build-image

push-image:
	$(CRI) push $(IMAGE)
.PHONY: push-image

build:
	go build cmd/kubectl-ditm.go
.PHONY: plugin
