#! /bin/bash

# Check if the server name already exists as a config...
INIT_FILE="${SERVER_DATA_DIR}/Server/${SERVER_NAME}.inited"
INI_FILE="${SERVER_DATA_DIR}/Server/${SERVER_NAME}.ini"
LOG_FILE="${SERVER_DATA_DIR}/Server/${SERVER_NAME}-container.log"

# Helpers
function report_and_log_config_value {
	if [ ! -f "$LOG_FILE" ]; then
		touch "$LOG_FILE";
	fi
	local config_name=$1
	if [[ -z $config_name ]]; then
		echo "Must pass config name to $0 function";
	fi
	
	local config_results
	config_results=$(grep "$config_name" "$INI_FILE")
	echo "$config_results";
	echo "$config_results" >> "$LOG_FILE";
}

function maybe_init_server_config {
	if [[ ! -f "${INI_FILE}" ]]; then
		echo "========================================================="
		echo "Starting server for 45 seconds to init configs..."
		echo "========================================================="
		timeout -k 9 45s bash "${STEAM_APP_DIR}/start-server.sh" \
						-servername "${SERVER_NAME}" \
						-adminpassword "${SERVER_ADMIN_CLI_PASS}"
		echo "========================================================="
		echo "Ending server, then setting up configuration..."
		echo "========================================================="
	fi
}

function config_set_server_public {
	if [ -f "$INI_FILE" ]; then
		echo "========================================================="
		echo "Setting server to Public setting now..."
		report_and_log_config_value "Public="
		if [ "${SERVER_PUBLIC}" -eq "1" ]; then
			sed -ri "s/^Public=(.*)$/Public=true/" "$INI_FILE"
		else
			sed -ri "s/^Public=(.*)$/Public=false/" "$INI_FILE"
		fi
		report_and_log_config_value "Public="
		echo "========================================================="
	fi
}

function config_set_server_upnp {
	if [ -f "$INI_FILE" ]; then
		echo "========================================================="
		echo "Setting server to UPnP setting now..."
		report_and_log_config_value "UPnP="
		if [ "${SERVER_UPNP}" -eq "0" ]; then
			echo "Turning OFF the UPnP setting"
			sed -ri "s/^UPnP=(.*)$/UPnP=false/" "$INI_FILE"
		else
			echo "Turning ON the UPnP setting"
			sed -ri "s/^UPnP=(.*)$/UPnP=true/" "$INI_FILE"
		fi
		report_and_log_config_value "UPnP="
		echo "========================================================="
	fi
}

function config_set_server_password {
	if [ -f "$INI_FILE" ]; then
		if [[ -n "$SERVER_PASSWORD" ]]; then
			echo "========================================================="
			echo "Server PW was provided, setting in config..."
			report_and_log_config_value "^Password="
			sed -ri "s/^Password=(.*)$/Password=${SERVER_PASSWORD}/" "$INI_FILE"
			report_and_log_config_value "^Password="
			echo "========================================================="
		fi
	fi
}

function config_set_server_rcon {
	if [ -f "$INI_FILE" ]; then
		if [[ -n "$SERVER_RCON_PASSWORD" ]]; then
			echo "========================================================="
			echo "Server RCONPort was provided, setting in config..."
			report_and_log_config_value "^RCONPort="
			sed -ri "s/^RCONPort=(.*)$/RCONPort=${SERVER_RCON_PORT}/" "$INI_FILE"
			report_and_log_config_value "^RCONPort="
			echo "========================================================="

			echo "========================================================="
			echo "Server RCON PW was provided, setting in config..."
			report_and_log_config_value "^RCONPassword="
			sed -ri "s/^RCONPassword=(.*)$/RCONPassword=${SERVER_RCON_PASSWORD}/" "$INI_FILE"
			report_and_log_config_value "^RCONPassword="
			echo "========================================================="
		fi
		if [[ -n $SERVER_RCON_DISABLED ]] && [[ $SERVER_RCON_DISABLED -eq "1" ]]; then
			echo "========================================================="
			echo "Will disable RCON since no ENV configs set..."
			sed -ri "s/^RCONPort=(.*)$/RCONPort=/" "$INI_FILE"
			sed -ri "s/^RCONPassword=(.*)$/RCONPassword=/" "$INI_FILE"
			echo "========================================================="
		fi
	fi
}

function config_set_server_mods {
	if [ -f "$INI_FILE" ]; then
		if [[ -n $SERVER_MODS ]] && [[ -n $SERVER_WORKSHOP_IDS ]]; then
			echo "========================================================="
			echo "Mod settings provide will configure now..."
			report_and_log_config_value "^Mods="
			sed -ri "s/^Mods=(.*)$/Mods=${SERVER_MODS}/" "$INI_FILE"
			report_and_log_config_value "^Mods="
			report_and_log_config_value "^WorkshopItems="
			sed -ri "s/^WorkshopItems=(.*)$/WorkshopItems=${SERVER_WORKSHOP_IDS}/" "$INI_FILE"
			report_and_log_config_value "^WorkshopItems="
			echo "========================================================="
		fi
	fi
}

function app_launcher_ram {
    LAUNCHER_JSON="${HOMEDIR}/project-zomboid-dedicated/ProjectZomboid64.json"
    if [ -f "$LAUNCHER_JSON" ]; then
        if [[ -n $SERVER_RAM ]]; then
            echo "========================================================="
            echo "Applying custom Server RAM limit: $SERVER_RAM..."

            # Log current -Xmx setting before modification
            local json_results
            json_results=$(grep -o '"-Xmx[^"]*"' "$LAUNCHER_JSON")
            echo "Before update: $json_results"
            echo "Before update: $json_results" >> "$LOG_FILE"

            # Backup the original JSON file
            cp "$LAUNCHER_JSON" "$LAUNCHER_JSON.bak"

            # Update -Xmx value
            sed -i "s/-Xmx[0-9]\+[mg]/-Xmx${SERVER_RAM}/" "$LAUNCHER_JSON"

            # Remove all existing -Xms values (to prevent duplicates)
            sed -i '/"-Xms[0-9]\+[mg]",/d' "$LAUNCHER_JSON"

            # Insert "-Xms" as a new entry after "-Xmx"
            sed -i "/-Xmx${SERVER_RAM}/a \                \"-Xms${SERVER_RAM}\"," "$LAUNCHER_JSON"


            # Log updated settings
            json_results=$(grep -o '"-Xmx[^"]*"' "$LAUNCHER_JSON")
            echo "After update: $json_results"
            echo "After update: $json_results" >> "$LOG_FILE"

            echo "========================================================="
        fi
    fi
}

# First boot loop...
if [[ ! -f "${INIT_FILE}" ]]; then
	maybe_init_server_config;

	if [ -f "$INI_FILE" ]; then
		echo "========================================================="
		echo "Setting Server Public Name & Description"
		report_and_log_config_value PublicName
		sed -ri "s/^PublicName=(.*)$/PublicName=${SERVER_DISPLAY_NAME}/" "$INI_FILE"
		report_and_log_config_value PublicName
		report_and_log_config_value PublicDescription
		sed -ri "s/^PublicDescription=(.*)$/PublicDescription=${SERVER_DESCRIPTION}/" "$INI_FILE"
		report_and_log_config_value PublicDescription
		echo "========================================================="

		touch "${INIT_FILE}"
		date >> "${INIT_FILE}"
	else
		echo "Setting up the configs crashed bud - sorry."
	fi
fi

config_set_server_public;
config_set_server_upnp;
config_set_server_password;
config_set_server_rcon;
config_set_server_mods;

app_launcher_ram;

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
