# https://developers.home-assistant.io/docs/add-ons/dockerfile
ARG BUILD_FROM=docker.io/library/debian:bullseye
FROM ${BUILD_FROM}

ENV DEBIAN_FRONTEND=noninteractive

# Update & install base dependencies (add debconf-utils for preseed)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl gpg gpg-agent apt-transport-https lsb-release debconf-utils && \
    rm -rf /var/lib/apt/lists/*

# Add CouchDB GPG key
RUN curl https://couchdb.apache.org/repo/keys.asc | apt-key add -

# Add CouchDB repository
RUN echo "deb https://apache.jfrog.io/artifactory/couchdb-deb/ $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/couchdb.list >/dev/null

# Preseed debconf (avoid interactive post-install questions)
RUN echo "couchdb couchdb/mode select standalone" | debconf-set-selections && \
    echo "couchdb couchdb/nodename string couchdb@localhost" | debconf-set-selections

# Install CouchDB (let package create user/group and directories)
RUN apt-get update && \
    apt-get install -y --no-install-recommends couchdb && \
    rm -rf /var/lib/apt/lists/*

# Copy the run script into the container
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]