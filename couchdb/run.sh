#!/usr/bin/with-contenv bashio

bashio::log.info "Configuring CouchDB..."

# Define file and directory paths
readonly COUCHDB_DATA_DIR="/data/couchdb"
readonly COUCHDB_CONFIG_FILE="/opt/couchdb/etc/local.d/hassio.ini"

# Get configuration options from Home Assistant UI
readonly COUCHDB_USER=$(bashio::config 'couchdb_user')
readonly COUCHDB_PASSWORD=$(bashio::config 'couchdb_password')

# Ensure the data directory exists
mkdir -p "${COUCHDB_DATA_DIR}"
chown -R couchdb:couchdb "${COUCHDB_DATA_DIR}"

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
chown couchdb:couchdb "${COUCHDB_CONFIG_FILE}"

bashio::log.info "Starting CouchDB server..."

# Start CouchDB in the foreground
exec /opt/couchdb/bin/couchdb