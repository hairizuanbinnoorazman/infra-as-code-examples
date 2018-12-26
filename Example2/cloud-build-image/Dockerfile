FROM ubuntu

ARG PACKER_VERSION=1.3.1
ARG PACKER_VERSION_SHA256SUM=254cf648a638f7ebd37dc1b334abe940da30b30ac3465b6e0a9ad59829932fa3

RUN apt-get -y update && apt-get -y install ca-certificates wget && rm -rf /var/lib/apt/lists/*
RUN wget "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip"
RUN echo "${PACKER_VERSION_SHA256SUM} packer_${PACKER_VERSION}_linux_amd64.zip" > checksum && sha256sum -c checksum
RUN apt-get -y update && apt-get -y install unzip && /usr/bin/unzip packer_${PACKER_VERSION}_linux_amd64.zip

FROM python:3.7
RUN apt-get -y update && apt-get -y install ca-certificates openssh-client && rm -rf /var/lib/apt/lists/*
ADD requirements.txt .
RUN pip install -r requirements.txt
RUN useradd -ms /bin/bash builder
USER builder
WORKDIR /home/builder
ENV USER builder
COPY --from=0 packer /usr/bin/packer
ENTRYPOINT ["/usr/bin/packer"]