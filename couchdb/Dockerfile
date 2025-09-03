# https://developers.home-assistant.io/docs/add-ons/dockerfile
ARG BUILD_FROM=docker.io/library/debian:bullseye
FROM ${BUILD_FROM}

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Update package list
RUN apt-get update

# Install dependencies
RUN apt-get install -y --no-install-recommends \
    ca-certificates curl gpg gpg-agent apt-transport-https lsb-release

# Create couchdb group to avoid group ID conflict
RUN groupadd -r couchdb
# Create couchdb user to fix installation script issues
RUN useradd -r -g couchdb -d /opt/couchdb -s /bin/bash couchdb

# Add CouchDB GPG key
RUN curl https://couchdb.apache.org/repo/keys.asc | apt-key add -

# Add CouchDB repository
RUN echo "deb https://apache.jfrog.io/artifactory/couchdb-deb/ $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/couchdb.list >/dev/null

# Update package list again
RUN apt-get update

# Install CouchDB
RUN apt-get install -y --no-install-recommends couchdb

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Create directories and set ownership
RUN mkdir -p /opt/couchdb/data /opt/couchdb/etc /opt/couchdb/var/log /opt/couchdb/var/run \
    && chown -R couchdb:couchdb /opt/couchdb

# Copy the run script into the container
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]