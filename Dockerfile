FROM debian

RUN apt-get update && \
    apt-get -y install wget telnet curl netcat dnsutils && \
    apt-get clean
