# https://developers.home-assistant.io/docs/add-ons/dockerfile
ARG BUILD_FROM=docker.io/library/debian:bullseye
FROM ${BUILD_FROM}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl gpg gpg-agent apt-transport-https lsb-release debconf-utils && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://couchdb.apache.org/repo/keys.asc | apt-key add -

RUN echo "deb https://apache.jfrog.io/artifactory/couchdb-deb/ $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/couchdb.list >/dev/null

RUN echo "couchdb couchdb/mode select standalone" | debconf-set-selections && \
    echo "couchdb couchdb/nodename string couchdb@localhost" | debconf-set-selections && \
    echo "couchdb couchdb/bindaddress string 0.0.0.0" | debconf-set-selections

# 自動サービス起動を抑止 (postinst が systemd を呼ぼうとして失敗するのを防ぐ)
RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# systemctl コマンドをモックして postinst の失敗を防ぐ
RUN printf '#!/bin/sh\necho "systemctl mock: $*"\nexit 0\n' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl

# invoke-rc.d コマンドもモックする
RUN printf '#!/bin/sh\necho "invoke-rc.d mock: $*"\nexit 0\n' > /usr/sbin/invoke-rc.d && chmod +x /usr/sbin/invoke-rc.d

RUN apt-get update && \
    apt-get install -y --no-install-recommends couchdb && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /usr/sbin/policy-rc.d /usr/bin/systemctl /usr/sbin/invoke-rc.d

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]