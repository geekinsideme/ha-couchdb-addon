# https://developers.home-assistant.io/docs/add-ons/dockerfile
ARG BUILD_FROM=docker.io/library/debian:bullseye
FROM ${BUILD_FROM}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl gpg gpg-agent apt-transport-https lsb-release debconf-utils strace && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://couchdb.apache.org/repo/keys.asc | apt-key add -

RUN echo "deb https://apache.jfrog.io/artifactory/couchdb-deb/ $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/couchdb.list >/dev/null

RUN echo "couchdb couchdb/mode select standalone" | debconf-set-selections && \
    echo "couchdb couchdb/nodename string couchdb@localhost" | debconf-set-selections && \
    echo "couchdb couchdb/bindaddress string 0.0.0.0" | debconf-set-selections

# 自動サービス起動を抑止
RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# systemctl コマンドをモックして詳細ログ出力
RUN printf '#!/bin/sh\necho "systemctl mock called with: $*" >&2\nif [ "$1" = "enable" ] || [ "$1" = "start" ] || [ "$1" = "daemon-reload" ]; then\n  echo "systemctl: mock success for $1" >&2\n  exit 0\nfi\necho "systemctl: unknown command $1" >&2\nexit 1\n' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl

# invoke-rc.d コマンドもモックして詳細ログ出力
RUN printf '#!/bin/sh\necho "invoke-rc.d mock called with: $*" >&2\nexit 0\n' > /usr/sbin/invoke-rc.d && chmod +x /usr/sbin/invoke-rc.d

# service コマンドもモック
RUN printf '#!/bin/sh\necho "service mock called with: $*" >&2\nexit 0\n' > /usr/sbin/service && chmod +x /usr/sbin/service

# update-rc.d コマンドもモック
RUN printf '#!/bin/sh\necho "update-rc.d mock called with: $*" >&2\nexit 0\n' > /usr/sbin/update-rc.d && chmod +x /usr/sbin/update-rc.d

# dpkg設定でpostinstの詳細ログを有効化
RUN echo 'DPkg::Pre-Install-Pkgs { "echo Installing: $*"; };' > /etc/apt/apt.conf.d/99debug

# CouchDBインストール前の環境確認
RUN echo "=== Environment check ===" && \
    ls -la /usr/sbin/ | grep -E "(policy-rc.d|invoke-rc.d|service|update-rc.d)" && \
    ls -la /usr/bin/ | grep systemctl && \
    echo "=== End environment check ==="

# CouchDBインストール（失敗時により詳細な情報を出力）
RUN set -x && \
    apt-get update && \
    echo "=== Starting CouchDB installation ===" && \
    apt-get install -y --no-install-recommends couchdb 2>&1 | tee /tmp/install.log || \
    (echo "=== Installation failed, checking logs ===" && \
     cat /tmp/install.log && \
     echo "=== Checking postinst script ===" && \
     cat /var/lib/dpkg/info/couchdb.postinst 2>/dev/null || echo "No postinst found" && \
     echo "=== Checking system state ===" && \
     ps aux 2>/dev/null || echo "No ps available" && \
     ls -la /etc/init.d/ 2>/dev/null || echo "No init.d" && \
     exit 1) && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /usr/sbin/policy-rc.d /usr/bin/systemctl /usr/sbin/invoke-rc.d /usr/sbin/service /usr/sbin/update-rc.d

# CouchDBユーザーが存在しない場合は手動で作成
RUN if ! id couchdb > /dev/null 2>&1; then \
        echo "Creating couchdb user..." && \
        groupadd -r couchdb && \
        useradd -r -g couchdb -d /opt/couchdb -s /bin/bash couchdb && \
        chown -R couchdb:couchdb /opt/couchdb; \
    fi

# データディレクトリを事前作成
RUN mkdir -p /data/couchdb && \
    chown -R couchdb:couchdb /data/couchdb

# ヘルスチェック用のスクリプトを作成
RUN cat > /healthcheck.sh << 'EOF'
#!/bin/bash
# CouchDBが起動しているかチェック
if curl -f -s http://localhost:5984/ > /dev/null 2>&1; then
    echo "CouchDB is running"
    exit 0
else
    echo "CouchDB is not responding"
    exit 1
fi
EOF

RUN chmod +x /healthcheck.sh

# ヘルスチェックを設定
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD /healthcheck.sh

COPY run.sh /
RUN chmod +x /run.sh

# ポートを公開
EXPOSE 5984

CMD [ "/run.sh" ]