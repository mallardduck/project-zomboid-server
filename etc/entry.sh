#!/bin/bash
echo "Loading Steam Release Branch for ProjectZomboid"
bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAM_APP_DIR}" \
        +login anonymous \
        +app_update "${STEAM_APP_ID}" validate \
        +quit

bash "${STEAM_APP_DIR}/start-server.sh" \
			-servername "${SERVER_NAME}"
