#! /bin/bash

# Check if the server name already exists as a config...
INIT_FILE="${SERVER_DATA_DIR}/Server/${SERVER_NAME}.inited"
INI_FILE="${SERVER_DATA_DIR}/Server/${SERVER_NAME}.ini"

# Helpers
function maybe_init_server_config {
	if [[ ! -f "${INI_FILE}" ]]; then
		echo "========================================================="
		echo "Starting server for 45 seconds to init configs..."
		echo "========================================================="
		timeout -k 9 45s bash "${STEAM_APP_DIR}/start-server.sh" \
						-servername "${SERVER_NAME}" \
						-adminpassword ${SERVER_ADMIN_CLI_PASS}
		echo "========================================================="
		echo "Ending server, then setting up configuration..."
		echo "========================================================="
	fi
}

function config_set_server_public {
	if [ -f $INI_FILE ]; then
		echo "========================================================="
		echo "Setting server to Public setting now..."
		grep "Public=" "$INI_FILE"
		if [ "${SERVER_PUBLIC}" -eq "1" ]; then
			sed -ri "s/^Public=(.*)$/Public=true/" "$INI_FILE"
		else
			sed -ri "s/^Public=(.*)$/Public=false/" "$INI_FILE"
		fi
		grep "Public=" "$INI_FILE"
		echo "========================================================="
	fi
}

function config_set_server_upnp {
	if [ -f $INI_FILE ]; then
		echo "========================================================="
		echo "Setting server to UPnP setting now..."
		grep "UPnP=" "$INI_FILE"
		if [ "${SERVER_UPNP}" -eq "0" ]; then
			echo "Turning OFF the UPnP setting"
			sed -ri "s/^UPnP=(.*)$/UPnP=false/" "$INI_FILE"
		else
			echo "Turning ON the UPnP setting"
			sed -ri "s/^UPnP=(.*)$/UPnP=true/" "$INI_FILE"
		fi
		grep "UPnP=" "$INI_FILE"
		echo "========================================================="
	fi
}

function config_set_server_password {
	if [ -f $INI_FILE ]; then
		if [[ ! -z "$SERVER_PASSWORD" ]]; then
			echo "========================================================="
			echo "Server PW was provided, setting in config..."
			grep "^Password=" "$INI_FILE"
			sed -ri "s/^Password=(.*)$/Password=${SERVER_PASSWORD}/" "$INI_FILE"
			grep "^Password=" "$INI_FILE"
			echo "========================================================="
		fi
	fi
}

function config_set_server_rcon {
	if [ -f $INI_FILE ]; then
		if [[ ! -z "$SERVER_RCON_PORT" ]] && [[ ! -z "$SERVER_RCON_PASSWORD" ]]; then
			echo "========================================================="
			echo "Server RCONPort was provided, setting in config..."
			grep "^RCONPort=" "$INI_FILE"
			sed -ri "s/^RCONPort=(.*)$/RCONPort=${SERVER_RCON_PORT}/" "$INI_FILE"
			grep "^RCONPort=" "$INI_FILE"
			echo "========================================================="

			echo "========================================================="
			echo "Server RCON PW was provided, setting in config..."
			grep "^RCONPassword=" "$INI_FILE"
			sed -ri "s/^RCONPassword=(.*)$/RCONPassword=${SERVER_RCON_PASSWORD}/" "$INI_FILE"
			grep "^RCONPassword=" "$INI_FILE"
			echo "========================================================="
		else
			echo "========================================================="
			echo "Will disable RCON since no ENV configs set..."
			sed -ri "s/^RCONPort=(.*)$/RCONPort=/" "$INI_FILE"
			sed -ri "s/^RCONPassword=(.*)$/RCONPassword=/" "$INI_FILE"
			echo "========================================================="
		fi
	fi
}

# First boot loop...
if [[ ! -f "${INIT_FILE}" ]]; then
	maybe_init_server_config;

	if [ -f $INI_FILE ]; then
		echo "========================================================="
		echo "Setting Server Public Name & Description"
		grep PublicName "$INI_FILE"
		sed -ri "s/^PublicName=(.*)$/PublicName=${SERVER_DISPLAY_NAME}/" "$INI_FILE"
		grep PublicName "$INI_FILE"
		grep PublicDescription "$INI_FILE"
		sed -ri "s/^PublicDescription=(.*)$/PublicDescription=${SERVER_DESCRIPTION}/" "$INI_FILE"
		grep PublicDescription "$INI_FILE"
		echo "========================================================="

		touch ${INIT_FILE}
		echo "$(date)" >> ${INIT_FILE}
	else
		echo "Setting up the configs crashed bud - sorry."
	fi
fi

config_set_server_public;
config_set_server_upnp;
config_set_server_password;
config_set_server_rcon;

# Start the actual server with the server name...
if [[ -f "${INIT_FILE}" ]]; then
	echo "========================================================="
	echo "Starting server, time to get to playing..."
	echo "========================================================="
	bash "${STEAM_APP_DIR}/start-server.sh" \
				-servername "${SERVER_NAME}"
else
	# In theory it should never reach this point...
	echo "========================================================="
	echo "CANNOT START SERVER"
	echo "========================================================="
fi
