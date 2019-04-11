FROM amazonlinux:2.0.20190228
LABEL maintainer="CriticalBlue Ltd."

# # BUILD DEPENDENCIES #
RUN yum update -y \
  && yum install -y epel-release yum-utils \
  && yum-config-manager --enable epel \
  && yum install -y \
    ansible \
    git \
    jq \
    tar \
    unzip \
    vim

# BUILD DEPENDENCIES #

## Golang

ENV GOLANG_VERSION 1.12.3
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 3924819eed16e55114f02d25d03e77c916ec40b7fd15c8acb5838b63135b03df

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
  && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
  && tar -C /usr/local -xzf golang.tar.gz \
  && rm golang.tar.gz

# Packer

ENV PACKER_VERSION 1.3.5
ENV PACKER_DOWNLOAD_URL https://releases.hashicorp.com/packer/"$PACKER_VERSION"/packer_"$PACKER_VERSION"_linux_amd64.zip
ENV PACKER_DOWNLOAD_SHA256 14922d2bca532ad6ee8e936d5ad0788eba96f773bcdcde8c2dc7c95f830841ec

RUN curl -fsSL "$PACKER_DOWNLOAD_URL" -o packer.zip \
  && echo "$PACKER_DOWNLOAD_SHA256 packer.zip" | sha256sum -c - \
  && unzip packer.zip -d /usr/local/bin/ \
  && rm packer.zip

# Avoid symlinked cracklib naming conflict
RUN rm /usr/sbin/packer

# Setup Go Environment Variables
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# Setup go file structure and install Go testing tools
RUN mkdir /go \
  && go get github.com/tebeka/go2xunit \
  && go get github.com/axw/gocov/gocov \
  && go get github.com/AlekSi/gocov-xml \
  && go get github.com/githubnemo/CompileDaemon

## Networking

ENV PORT 8081
ENV CBPORT 8082

EXPOSE $PORT
EXPOSE $CBPORT
