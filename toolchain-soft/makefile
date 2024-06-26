.PHONY: shell
.PHONY: clean
	
TOOLCHAIN_NAME=turro1975/my-rg35xx-toolchain:soft
WORKSPACE_DIR := $(shell cd .. && pwd)/


CONTAINER_NAME=$(shell docker ps -f "ancestor=$(TOOLCHAIN_NAME)" --format "{{.Names}}")
BOLD=$(shell tput bold)
NORM=$(shell tput sgr0)

.build: Dockerfile
	$(info $(BOLD)Building $(TOOLCHAIN_NAME)...$(NORM))
	mkdir -p ./workspace
	docker build --platform=linux/amd64 -t $(TOOLCHAIN_NAME) .
	touch .build

ifeq ($(CONTAINER_NAME),)
shell: .build
	$(info $(BOLD)Starting $(TOOLCHAIN_NAME)...$(NORM))
	docker run --platform linux/amd64 -it --rm -v "$(WORKSPACE_DIR)":/root/workspace $(TOOLCHAIN_NAME) /bin/bash
else
shell:
	$(info $(BOLD)Connecting to running $(TOOLCHAIN_NAME)...$(NORM))
	docker exec -it $(CONTAINER_NAME) /bin/bash  
endif

clean:
	$(info $(BOLD)Removing $(TOOLCHAIN_NAME)...$(NORM))
	docker rmi $(TOOLCHAIN_NAME)
	rm -f .build

push:
	$(info $(BOLD)Pushing $(TOOLCHAIN_NAME)...$(NORM))
	docker push $(TOOLCHAIN_NAME)
