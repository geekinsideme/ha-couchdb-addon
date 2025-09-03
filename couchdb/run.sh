#!/bin/bash
set -e

echo "Configuring CouchDB..."

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

	[couchdb]
	database_dir = ${COUCHDB_DATA_DIR}
	view_index_dir = ${COUCHDB_DATA_DIR}
EOT

# Set correct ownership for the config file
if id couchdb > /dev/null 2>&1; then
    chown couchdb:couchdb "${COUCHDB_CONFIG_FILE}"
else
    echo "Warning: couchdb user not found, skipping ownership change"
fi

echo "Starting CouchDB server..."

# Start CouchDB in the foreground
exec /opt/couchdb/bin/couchdb