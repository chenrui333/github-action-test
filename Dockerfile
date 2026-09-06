FROM golang:1.27@sha256:512690a5660563b57d37ecc31129e7f136e831db2aed24a1dbeb8ad7380dc0fa

# https://packages.debian.org/stable/unzip
# renovate: release=stable depName=unzip
ARG UNZIP_VERSION=6.0-29
RUN apt-get update && \
    apt-get install -y --no-install-recommends unzip=${UNZIP_VERSION} && \
    rm -rf /var/lib/apt/lists/*

# Only amd64 and arm64 have binary releases for every bundled tool.
ARG TARGETARCH

# Install Terraform
# renovate: datasource=github-releases depName=hashicorp/terraform versioning=hashicorp
ARG TERRAFORM_VERSION=1.16.1
RUN case "$TARGETARCH" in amd64|arm64) ARCH="$TARGETARCH" ;; *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; esac && \
    curl --retry 3 --retry-all-errors --connect-timeout 20 --max-time 300 -fsSLo terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip && \
    curl --retry 3 --retry-all-errors --connect-timeout 20 --max-time 300 -fsSLo terraform_SHA256SUMS https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    awk -v file="terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" '$2 == file {print $1 "  terraform.zip"}' terraform_SHA256SUMS > terraform.sha256 && \
    test -s terraform.sha256 && sha256sum -c terraform.sha256 && \
    mkdir -p /usr/local/bin/tf/versions/${TERRAFORM_VERSION} && \
    unzip terraform.zip -d /usr/local/bin/tf/versions/${TERRAFORM_VERSION} && \
    ln -s /usr/local/bin/tf/versions/${TERRAFORM_VERSION}/terraform /usr/local/bin/terraform && \
    rm terraform.zip terraform_SHA256SUMS terraform.sha256

# Install conftest
# renovate: datasource=github-releases depName=open-policy-agent/conftest
ARG CONFTEST_VERSION=0.58.0
RUN case "$TARGETARCH" in amd64) ARCH="x86_64" ;; arm64) ARCH="arm64" ;; *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; esac && \
    curl --retry 3 --retry-all-errors --connect-timeout 20 --max-time 300 -fLOsS https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_${ARCH}.tar.gz && \
    curl --retry 3 --retry-all-errors --connect-timeout 20 --max-time 300 -fLOsS https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/checksums.txt && \
    awk -v file="conftest_${CONFTEST_VERSION}_Linux_${ARCH}.tar.gz" '$2 == file {print}' checksums.txt > conftest.sha256 && \
    test -s conftest.sha256 && sha256sum -c conftest.sha256 && \
    mkdir -p /usr/local/bin/cft/versions/${CONFTEST_VERSION} && \
    tar -C  /usr/local/bin/cft/versions/${CONFTEST_VERSION} -xzf conftest_${CONFTEST_VERSION}_Linux_${ARCH}.tar.gz && \
    ln -s /usr/local/bin/cft/versions/${CONFTEST_VERSION}/conftest /usr/local/bin/conftest${CONFTEST_VERSION} && \
    rm conftest_${CONFTEST_VERSION}_Linux_${ARCH}.tar.gz && \
    rm checksums.txt conftest.sha256

# renovate: datasource=github-tags depName=golang/tools
ARG GOIMPORTS_VERSION=0.49.0
RUN go install golang.org/x/tools/cmd/goimports@v${GOIMPORTS_VERSION}

# A successful cross-platform build must also execute the bundled binaries.
RUN terraform version && conftest${CONFTEST_VERSION} --version && \
    printf 'package main\nfunc main() {}\n' | goimports
