FROM amazonlinux:2016.09

# BUILD DEPENDENCIES #
RUN yum install -y epel-release yum-utils \
  && yum-config-manager --enable epel \
  && yum install -y \
    ansible \
    git \
    jq \
    unzip

# BUILD DEPENDENCIES #

## Golang

ENV GOLANG_VERSION 1.15.5
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 9a58494e8da722c3aef248c9227b0e9c528c7318309827780f16220998180a0d

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
  && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
  && tar -C /usr/local -xzf golang.tar.gz \
  && rm golang.tar.gz

# Packer

ENV PACKER_VERSION 1.0.4
ENV PACKER_DOWNLOAD_URL https://releases.hashicorp.com/packer/"$PACKER_VERSION"/packer_"$PACKER_VERSION"_linux_amd64.zip
ENV PACKER_DOWNLOAD_SHA256 646da085cbcb8c666474d500a44d933df533cf4f1ff286193d67b51372c3c59e

RUN curl -fsSL "$PACKER_DOWNLOAD_URL" -o packer.zip \
  && echo "$PACKER_DOWNLOAD_SHA256 packer.zip" | sha256sum -c - \
  && unzip packer.zip -d /usr/local/bin/ \
  && rm packer.zip

# Avoid symlinked cracklib naming conflict
RUN rm /usr/sbin/packer

# Setup Go Environment
RUN mkdir /go

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

## Install Go testing tools
RUN go get github.com/tebeka/go2xunit
RUN go get github.com/axw/gocov/gocov
RUN go get github.com/AlekSi/gocov-xml

## CompileDaemon
RUN go get github.com/githubnemo/CompileDaemon

## Networking

ENV PORT 8081
ENV CBPORT 8082

EXPOSE $PORT
EXPOSE $CBPORT
