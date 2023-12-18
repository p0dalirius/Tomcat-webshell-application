
.PHONY: build img

IMGNAME := build_tomcat_webshell

all : build tomcat_9_and_lower tomcat_10_and_upper

clean:
	@rm -rf $(shell pwd)/webshell/tomcat_9_and_lower/dist/
	@rm -rf $(shell pwd)/webshell/tomcat_10_and_upper/dist/

build: clean
	@docker build -t $(IMGNAME):latest -f Dockerfile .


tomcat_9_and_lower:
	@docker run --rm -it -v $(shell pwd)/webshell/tomcat_9_and_lower/:/build/ $(IMGNAME)

tomcat_10_and_upper:
	@docker run --rm -it -v $(shell pwd)/webshell/tomcat_10_and_upper/:/build/ $(IMGNAME)

release:
	@echo "[+] Creating tomcat-webshells.tar.gz"
	@cd ./webshell/; rm ../tomcat-webshells.tar.gz; tar czvf ../tomcat-webshells.tar.gz -- \
		./tomcat_9_and_lower/dist/1.3.0/webshell.war \
		./tomcat_10_and_upper/dist/1.3.0/webshell.war
	echo "[+] Creating tomcat-webshells.zip"
	@cd ./webshell/; rm ../tomcat-webshells.zip; zip -r ../tomcat-webshells.zip -- \
		./tomcat_9_and_lower/dist/1.3.0/webshell.war \
		./tomcat_10_and_upper/dist/1.3.0/webshell.war

shell:
	@docker exec -it $(shell docker ps | grep $(IMGNAME) | awk '{split($$0,a," "); print a[1]}') bash

stop:
	@docker stop $(shell docker ps | grep $(IMGNAME) | awk '{split($$0,a," "); print a[1]}')