FROM amazonlinux:2.0.20240412.0
LABEL maintainer="CriticalBlue Ltd."

# BUILD DEPENDENCIES #

RUN yum update -y \
  && yum install -y \
    bind-utils \
    git \
    jq \
    python3 python3-pip python3-setuptools \
    rsync \
    sudo \
    tar \
    tree \
    unzip \
    yum-utils \
    vim \
  && sudo amazon-linux-extras install python3.8 epel -y \
  && sudo -H python3.8 -m pip install ansible==6.7.0 \
  && sudo yum-config-manager --enable epel \
  && yum install git-lfs -y

## AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm awscliv2.zip

## Golang

ENV GOLANG_VERSION 1.21.10
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 e330e5d977bf4f3bdc157bc46cf41afa5b13d66c914e12fd6b694ccda65fcf92

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
  && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
  && tar -C /usr/local -xzf golang.tar.gz \
  && rm golang.tar.gz

ENV GOLANG_VERSION ""
ENV GOLANG_DOWNLOAD_URL ""
ENV GOLANG_DOWNLOAD_SHA256 ""

# Packer

ENV PACKER_VERSION 1.9.5
ENV PACKER_DOWNLOAD_URL https://releases.hashicorp.com/packer/"$PACKER_VERSION"/packer_"$PACKER_VERSION"_linux_amd64.zip
ENV PACKER_DOWNLOAD_SHA256 6f8272658a6d606583c2b3deaad272233db6e84a6ee651bf17a0d46d8cea4a9c

# Install packer; removing the symlinked cracklib naming conflict that would
# prevent the newly installed executable from being found
RUN curl -fsSL "$PACKER_DOWNLOAD_URL" -o packer.zip \
  && echo "$PACKER_DOWNLOAD_SHA256 packer.zip" | sha256sum -c - \
  && unzip packer.zip -d /usr/local/bin/ \
  && rm packer.zip \
  && rm /usr/sbin/packer

ENV PACKER_VERSION ""
ENV PACKER_DOWNLOAD_URL ""
ENV PACKER_DOWNLOAD_SHA256 ""

# Create the working directory
RUN mkdir /go

WORKDIR /go

# Setup Go Environment Variables
ENV GOPATH /go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

# Install Go testing tools
#
# Configure git to use ssh for retrieving go dependencies from gitlab
RUN go install github.com/tebeka/go2xunit@latest \
  && go install github.com/axw/gocov/gocov@latest \
  && go install github.com/AlekSi/gocov-xml@latest \
  && go install github.com/githubnemo/CompileDaemon@latest

# Add the tester user - always use id 1000 and add additional root group
RUN adduser -m --uid 1000 -G root tester \
  && echo "tester ALL = NOPASSWD: ALL" > /etc/sudoers.d/tester-init \
  && echo "tester ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/tester-init
# Don't switch to user - initial CI setup needs to run as root
# USER tester

## Networking
ENV PORT 8081
ENV CBPORT 8082

EXPOSE $PORT
EXPOSE $CBPORT
