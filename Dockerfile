FROM ubuntu:latest

RUN apt-get -y -q update; \
    apt-get -y -q install openjdk-8-jre gradle

RUN mkdir -p /build/
WORKDIR /build/
VOLUME /build/

CMD ["bash", "/build/build.sh"]
