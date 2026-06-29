#!/bin/bash
echo "Loading Steam Release Branch for ProjectZomboid"

BETA_FLAG=()
if [[ -n "${STEAM_BETA_BRANCH}" ]]; then
    echo "Using beta branch: ${STEAM_BETA_BRANCH}"
    BETA_FLAG=(-beta "${STEAM_BETA_BRANCH}")
fi

steamcmd +force_install_dir "${STEAM_APP_DIR}" \
        +login anonymous \
        +app_update "${STEAM_APP_ID}" "${BETA_FLAG[@]}" validate \
        +quit

bash "${SCRIPTS_DIR}/start.sh"
