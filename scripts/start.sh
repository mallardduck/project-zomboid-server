#! /bin/bash

# Check if the server name already exists as a config...
INIT_FILE="${SERVER_DATA_DIR}/Server/${SERVER_NAME}.inited"
INI_FILE="${SERVER_DATA_DIR}/Server/${SERVER_NAME}.ini"
if [[ ! -f "${INIT_FILE}" ]]; then
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
	if [ -f $INI_FILE ]; then
		if [ "${SERVER_PUBLIC}" -eq "1" ]; then
			echo "========================================================="
			echo "Setting server to Public now..."
			grep "Public=" "$INI_FILE"
			sed -ri "s/^Public=(.*)$/Public=true/" "$INI_FILE"
			grep "Public=" "$INI_FILE"
			echo "========================================================="
		fi
		if [ "${SERVER_UPNP}" -eq "0" ]; then
			echo "========================================================="
			echo "Turning OFF the UPnP setting"
			grep "UPnP=" "$INI_FILE"
			sed -ri "s/^UPnP=true$/UPnP=false/" "$INI_FILE"
			grep "UPnP=" "$INI_FILE"
			echo "========================================================="
		fi
		echo "========================================================="
		echo "Setting Server Public Name & Description"
		grep PublicName "$INI_FILE"
		sed -ri "s/^PublicName=(.*)$/PublicName=${SERVER_DISPLAY_NAME}/" "$INI_FILE"
		grep PublicName "$INI_FILE"
		grep PublicDescription "$INI_FILE"
		sed -ri "s/^PublicDescription=(.*)$/PublicDescription=${SERVER_DESCRIPTION}/" "$INI_FILE"
		grep PublicDescription "$INI_FILE"
		echo "========================================================="
		if [[ ! -z "$SERVER_PASSWORD" ]]; then
			echo "========================================================="
			echo "Server PW was provided, setting in config..."
			grep "^Password=" "$INI_FILE"
			sed -ri "s/^Password=(.*)$/Password=${SERVER_PASSWORD}/" "$INI_FILE"
			grep "^Password=" "$INI_FILE"
			echo "========================================================="
		fi
    echo "========================================================="
    echo "Server PW was provided, setting in config..."
    grep "^RCONPort=" "$INI_FILE"
    sed -ri "s/^RCONPort=(.*)$/RCONPort=${SERVER_RCON_PORT}/" "$INI_FILE"
    grep "^RCONPort=" "$INI_FILE"
    echo "========================================================="
    if [[ ! -z "$SERVER_RCON_PASSWORD" ]]; then
      echo "========================================================="
      echo "Server RCON PW was provided, setting in config..."
      grep "^RCONPassword=" "$INI_FILE"
      sed -ri "s/^RCONPassword=(.*)$/RCONPassword=${SERVER_RCON_PASSWORD}/" "$INI_FILE"
      grep "^RCONPassword=" "$INI_FILE"
      echo "========================================================="
    fi
		touch ${INIT_FILE}
		echo "$(date)" > ${INIT_FILE}
	fi
fi

# Start the actual server with the server name...
if [[ -f "${INIT_FILE}" ]]; then
	echo "========================================================="
	echo "Starting server, time to get to playing..."
	echo "========================================================="
	bash "${STEAM_APP_DIR}/start-server.sh" \
				-servername "${SERVER_NAME}"
else
	echo "========================================================="
	echo "CANNOT START SERVER"
	echo "========================================================="
fi
