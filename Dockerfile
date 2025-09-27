FROM openjdk:25-jdk-slim@sha256:4d9bb48a3d5c2015a5e67eeab7575b6b11eda252aee651e632ef57d24aaf2d82

ENV PHOTON_VERSION=0.6.2

# Install pbzip2 for parallel extraction
RUN apt-get update \
    && apt-get -y install \
    lbzip2 pbzip2 bzip2 \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /photon
ADD https://github.com/komoot/photon/releases/download/${PHOTON_VERSION}/photon-${PHOTON_VERSION}.jar /photon/photon.jar
COPY entrypoint.sh ./entrypoint.sh

VOLUME /photon/photon_data
EXPOSE 2322

ENTRYPOINT ["/photon/entrypoint.sh"]
