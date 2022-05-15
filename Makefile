
.PHONY: build img

IMGNAME := build_tomcat_webshell

all : build tomcat_9_and_lower

build:
	@docker build -t $(IMGNAME):latest -f Dockerfile .

tomcat_9_and_lower:
	@docker run --rm -it -v $(shell pwd)/webshell/tomcat_9_and_lower/:/build/ $(IMGNAME)

tomcat_10_and_upper:
	@docker run --rm -it -v $(shell pwd)/webshell/tomcat_10_and_upper/:/build/ $(IMGNAME)


shell:
	@docker exec -it $(shell docker ps | grep $(IMGNAME) | awk '{split($$0,a," "); print a[1]}') bash

stop:
	@docker stop $(shell docker ps | grep $(IMGNAME) | awk '{split($$0,a," "); print a[1]}')