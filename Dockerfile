FROM openjdk:25-oracle@sha256:e0d8204f9d426e92bad67e2e547acec5ab48fd31cdbc05c804b00fac79a29aaa

ENV PHOTON_VERSION=0.6.2

# Install pbzip2 for parallel extraction
RUN apt-get update \
    && apt-get -y install \
    pbzip2 \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /photon
ADD https://github.com/komoot/photon/releases/download/${PHOTON_VERSION}/photon-${PHOTON_VERSION}.jar /photon/photon.jar
COPY entrypoint.sh ./entrypoint.sh

VOLUME /photon/photon_data
EXPOSE 2322

ENTRYPOINT ["/photon/entrypoint.sh"]
