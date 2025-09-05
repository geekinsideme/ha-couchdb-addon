#!/bin/bash
set -e

echo "============================================="
echo "Script started at: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Configuring CouchDB... "

# Define file and directory paths
readonly COUCHDB_DATA_DIR="/data/couchdb"
readonly COUCHDB_CONFIG_FILE="/opt/couchdb/etc/local.d/hassio.ini"

# Get configuration options from environment variables (fallback to defaults)
readonly COUCHDB_USER="${COUCHDB_USER:-admin}"
readonly COUCHDB_PASSWORD="${COUCHDB_PASSWORD:-password}"

# Ensure the data directory exists
mkdir -p "${COUCHDB_DATA_DIR}"

# Check if couchdb user exists, if not create it
if ! id couchdb > /dev/null 2>&1; then
    echo "Creating couchdb user..."
    groupadd -r couchdb 2>/dev/null || true
    useradd -r -g couchdb -d /opt/couchdb -s /bin/bash couchdb 2>/dev/null || true
fi

chown -R couchdb:couchdb "${COUCHDB_DATA_DIR}"

# Create the configuration directory if it doesn't exist
mkdir -p "$(dirname "${COUCHDB_CONFIG_FILE}")"

# Create the configuration file from user options
# This will set the admin user/password, bind to all network interfaces,
# and specify the data directory.
cat > "${COUCHDB_CONFIG_FILE}" <<- EOT
	[admins]
	${COUCHDB_USER} = ${COUCHDB_PASSWORD}

	[chttpd]
	bind_address = 0.0.0.0
    require_valid_user = true
    max_http_request_size = 4294967296

    [chttpd_auth]
    require_valid_user = true
    authentication_redirect = /_utils/session.html

	[couchdb]
	database_dir = ${COUCHDB_DATA_DIR}
	view_index_dir = ${COUCHDB_DATA_DIR}
    single_node=true
    max_document_size = 50000000

    [httpd]
    WWW-Authenticate = Basic realm="couchdb"
    enable_cors = true

    [cors]
    origins = app://obsidian.md,capacitor://localhost,http://localhost
    credentials = true
    headers = accept, authorization, content-type, origin, referer
    methods = GET, PUT, POST, HEAD, DELETE
    max_age = 3600
EOT

# Set correct ownership for the config file
if id couchdb > /dev/null 2>&1; then
    chown couchdb:couchdb "${COUCHDB_CONFIG_FILE}"
else
    echo "Warning: couchdb user not found, skipping ownership change"
fi

echo "Starting CouchDB server..."

# Start CouchDB in the background first to check if it starts properly
/opt/couchdb/bin/couchdb &
COUCHDB_PID=$!

# Wait for CouchDB to start
echo "Waiting for CouchDB to start..."
for i in {1..30}; do
    if curl -f -s http://localhost:5984/ > /dev/null 2>&1; then
        echo "CouchDB is running and responding on port 5984"
        echo "CouchDB welcome response:"
        curl -s http://localhost:5984/ | head -5
        echo ""
        echo "=== CouchDB Web UI Access Information ==="
        echo "Web UI (Fauxton): http://[YOUR_HA_IP]:5984/_utils/"
        echo "Username: ${COUCHDB_USER}"
        echo "Password: ${COUCHDB_PASSWORD}"
        echo "API Endpoint: http://[YOUR_HA_IP]:5984/"
        echo "============================================="
        break
    fi
    echo "Waiting for CouchDB... ($i/30)"
    sleep 2
done

# Check if CouchDB is still running
if ! kill -0 $COUCHDB_PID 2>/dev/null; then
    echo "ERROR: CouchDB process has died"
    exit 1
fi

# Stop the background process and start in foreground
kill $COUCHDB_PID
wait $COUCHDB_PID 2>/dev/null

echo "CouchDB startup verified, starting in foreground..."
# Start CouchDB in the foreground
exec /opt/couchdb/bin/couchdb