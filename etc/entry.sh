#!/bin/bash
echo "Loading Steam Release Branch for ProjectZomboid"
bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAM_APP_DIR}" \
        +login anonymous \
        +app_update "${STEAM_APP_ID}" validate \
        +quit

# Change default port on
sed -i -e 's/DefaultPort=16261/'"DefaultPort=${SERVER_PORT}"'/g' "/root/Zomboid/Server/${SERVER_NAME}.ini"

bash "${STEAM_APP_DIR}/start-server.sh" \
			-servername "${SERVER_NAME}"
