FROM amazonlinux:2.0.20210126.0
LABEL maintainer="CriticalBlue Ltd."

# BUILD DEPENDENCIES #
#    python3 python3-pip python3-setuptools \
#  && sudo -H pip3 install ansible==2.4.6

RUN yum update -y \
  && yum install -y \
    git \
    jq \
    python3 python3-pip python3-setuptools \
    rsync \
    sudo \
    tar \
    unzip \
    yum-utils \
    vim \
  && sudo -H pip3 install ansible==2.5.14

# RUN yum update -y \
#   && yum install -y \
#     git \
#     jq \
#     rsync \
#     sudo \
#     tar \
#     unzip \
#     yum-utils \
#     vim \
#   && amazon-linux-extras install -y ansible2=2.4.6

# BUILD DEPENDENCIES #

## Golang

ENV GOLANG_VERSION 1.15.6
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 3918e6cc85e7eaaa6f859f1bdbaac772e7a825b0eb423c63d3ae68b21f84b844

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
  && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
  && tar -C /usr/local -xzf golang.tar.gz \
  && rm golang.tar.gz

# Packer

ENV PACKER_VERSION 1.5.6
ENV PACKER_DOWNLOAD_URL https://releases.hashicorp.com/packer/"$PACKER_VERSION"/packer_"$PACKER_VERSION"_linux_amd64.zip
ENV PACKER_DOWNLOAD_SHA256 2abb95dc3a5fcfb9bf10ced8e0dd51d2a9e6582a1de1cab8ccec650101c1f9df

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
