FROM amazonlinux:2.0.20200207.1
LABEL maintainer="CriticalBlue Ltd."

# BUILD DEPENDENCIES #
RUN yum update -y \
  && yum install -y \
    git \
    jq \
    rsync \
    sudo \
    tar \
    unzip \
    yum-utils \
    vim \
  && amazon-linux-extras install -y ansible2=2.4.6
# BUILD DEPENDENCIES #

## Golang

ENV GOLANG_VERSION 1.14.1
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 2f49eb17ce8b48c680cdb166ffd7389702c0dec6effa090c324804a5cac8a7f8

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
  && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
  && tar -C /usr/local -xzf golang.tar.gz \
  && rm golang.tar.gz

# Packer

ENV PACKER_VERSION 1.5.5
ENV PACKER_DOWNLOAD_URL https://releases.hashicorp.com/packer/"$PACKER_VERSION"/packer_"$PACKER_VERSION"_linux_amd64.zip
ENV PACKER_DOWNLOAD_SHA256 07f28a1a033f4bcd378a109ec1df6742ac604e7b122d0316d2cddb3c2f6c24d1

# Install packer; removing the symlinked cracklib naming conflict that would
# prevent the newly installed executable from being found
#
# Then add a new "tester" user for performing the builds, add tester to the
# sudoers list
#
# Then create the /go root directory and change its owner to tester
RUN curl -fsSL "$PACKER_DOWNLOAD_URL" -o packer.zip \
  && echo "$PACKER_DOWNLOAD_SHA256 packer.zip" | sha256sum -c - \
  && unzip packer.zip -d /usr/local/bin/ \
  && rm packer.zip \
  && rm /usr/sbin/packer \
  && adduser tester \
  && echo "tester ALL = NOPASSWD: ALL" > /etc/sudoers.d/tester-init \
  && echo "tester ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/tester-init \
  && mkdir /go \
  && chown -R tester:tester /go

# Switch to tester user
USER tester
WORKDIR /go

# Setup Go Environment Variables
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# Install Go testing tools
#
# Configure git to use ssh for retrieving go dependencies from gitlab
RUN go get github.com/tebeka/go2xunit \
  && go get github.com/axw/gocov/gocov \
  && go get github.com/AlekSi/gocov-xml \
  && go get github.com/githubnemo/CompileDaemon

## Networking
ENV PORT 8081
ENV CBPORT 8082

EXPOSE $PORT
EXPOSE $CBPORT
