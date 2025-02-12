FROM golang:1.23@sha256:927112936d6b496ed95f55f362cc09da6e3e624ef868814c56d55bd7323e0959

# https://packages.debian.org/stable/upzip
# renovate: release=stable depName=unzip
ARG UNZIP_VERSION=6.0-28
RUN apt-get update && \
    apt-get install -y unzip=${UNZIP_VERSION}

# Install Terraform
# renovate: datasource=github-releases depName=hashicorp/terraform versioning=hashicorp
ARG TERRAFORM_VERSION=1.10.5
RUN case $(uname -m) in x86_64|amd64) ARCH="amd64" ;; aarch64|arm64|armv7l) ARCH="arm64" ;; esac && \
    wget -nv -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip && \
    mkdir -p /usr/local/bin/tf/versions/${TERRAFORM_VERSION} && \
    unzip terraform.zip -d /usr/local/bin/tf/versions/${TERRAFORM_VERSION} && \
    ln -s /usr/local/bin/tf/versions/${TERRAFORM_VERSION}/terraform /usr/local/bin/terraform && \
    rm terraform.zip

# Install conftest
# renovate: datasource=github-releases depName=open-policy-agent/conftest
ARG CONFTEST_VERSION=0.56.0
RUN case $(uname -m) in x86_64|amd64) ARCH="x86_64" ;; aarch64|arm64|armv7l) ARCH="arm64" ;; esac && \
    curl -LOs https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_${ARCH}.tar.gz && \
    curl -LOs https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/checksums.txt && \
    sed -n "/conftest_${CONFTEST_VERSION}_Linux_${ARCH}.tar.gz/p" checksums.txt | sha256sum -c && \
    mkdir -p /usr/local/bin/cft/versions/${CONFTEST_VERSION} && \
    tar -C  /usr/local/bin/cft/versions/${CONFTEST_VERSION} -xzf conftest_${CONFTEST_VERSION}_Linux_${ARCH}.tar.gz && \
    ln -s /usr/local/bin/cft/versions/${CONFTEST_VERSION}/conftest /usr/local/bin/conftest${CONFTEST_VERSION} && \
    rm conftest_${CONFTEST_VERSION}_Linux_${ARCH}.tar.gz && \
    rm checksums.txt

RUN go install golang.org/x/tools/cmd/goimports@latest
