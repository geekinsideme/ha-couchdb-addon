# https://developers.home-assistant.io/docs/add-ons/dockerfile
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and add the official Apache CouchDB repository
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl gpg apt-transport-https lsb-release \
    && curl https://couchdb.apache.org/repo/keys.asc | gpg --dearmor | tee /usr/share/keyrings/couchdb-archive-keyring.gpg >/dev/null 2>&1 \
    && echo "deb [signed-by=/usr/share/keyrings/couchdb-archive-keyring.gpg] https://apache.jfrog.io/artifactory/couchdb-deb/ $(lsb_release -cs) main" \
        | tee /etc/apt/sources.list.d/couchdb.list >/dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends couchdb \
    && rm -rf /var/lib/apt/lists/*

# Copy the run script into the container
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]