FROM openjdk:25-jdk-slim@sha256:90191c4b15648d3b81e112ba067fe525c2fe70cd53f2cc3cb205d8ffcc05e8de

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
