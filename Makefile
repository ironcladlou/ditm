IMAGE=docker.io/ironcladlou/ditm
CRI=docker

.PHONY: build-image
build-image:
	$(CRI) build -t $(IMAGE) .

.PHONY: push-image
push-image:
	$(CRI) push $(IMAGE)
