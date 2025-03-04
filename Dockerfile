FROM amazoncorretto:21-al2023
ARG TARGETPLATFORM

# our entrypoint script depends on xargs which is not installed by
# default on al2023
# https://github.com/amazonlinux/amazon-linux-2023/issues/355
RUN dnf install -y findutils

# Tweak JVM DNS cache TTL for faster failover in cases when AWS restarts instances
# See https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/java-dg-jvm-ttl.html
ENV NETWORKADDRESS_CACHE_TTL=60
# Uncomments an existing line in java.security and updates its value to the one defined by env variable
# #networkaddress.cache.ttl=-1 --> networkaddress.cache.ttl=5
RUN sed -i -E "s/#(networkaddress\.cache\.ttl)=(.*)/\1=$NETWORKADDRESS_CACHE_TTL/g" $JAVA_HOME/conf/security/java.security

# Timezone needed for correct flume logging
ENV TZ=America/New_York
# note: only needed because we send email in process which refer to static resources
ENV READ_RESOURCE_MANIFEST_FROM_DISK=true
ENV RESOURCE_MANIFEST_PATH=/app/resource-manifest.json

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN mkdir -p /usr/local/img_root/photo_upload/member

# install hurl, a readiness checking tool for health checks
# we may want to consider creating a base image for deployments with this
# preinstalled if this adds a undesirable about of docker build time

ARG HURL_VERSION=6.0.0
ARG HURL_AMD64_MD5=bafd0e2a44c2e4eaef79a6af045ae15d
ARG HURL_ARM_MD5=e35b52e0e32f2d9d86bf8c9d406ae15c

RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  dnf install -y tar gzip \
  && curl -sL https://github.com/Orange-OpenSource/hurl/releases/download/${HURL_VERSION}/hurl-${HURL_VERSION}-x86_64-unknown-linux-gnu.tar.gz \
  | tar xvz -C /tmp \
  && echo "$HURL_AMD64_MD5 /tmp/hurl-${HURL_VERSION}-x86_64-unknown-linux-gnu/bin/hurl" | md5sum -c \
  && mv /tmp/hurl-${HURL_VERSION}-x86_64-unknown-linux-gnu /tmp/hurl; \
  fi

RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
  dnf install -y tar gzip \
  && curl -sL https://github.com/Orange-OpenSource/hurl/releases/download/${HURL_VERSION}/hurl-${HURL_VERSION}-aarch64-unknown-linux-gnu.tar.gz \
  | tar xvz -C /tmp \
  && echo "$HURL_ARM_MD5 /tmp/hurl-${HURL_VERSION}-aarch64-unknown-linux-gnu/bin/hurl" | md5sum -c \
  && mv /tmp/hurl-${HURL_VERSION}-aarch64-unknown-linux-gnu /tmp/hurl; \
  fi

ENV PATH="$PATH:/tmp/hurl"

WORKDIR /app
