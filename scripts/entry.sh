#!/bin/bash
echo "Loading Steam Release Branch for ProjectZomboid"

BETA_FLAG=()
if [[ -n "${STEAM_BETA_BRANCH}" ]]; then
    echo "Using beta branch: ${STEAM_BETA_BRANCH}"
    BETA_FLAG=(-beta "${STEAM_BETA_BRANCH}")
fi

WORKSHOP_FLAGS=()
if [[ -n "${SERVER_WORKSHOP_IDS}" ]]; then
    echo "Will download workshop mods: ${SERVER_WORKSHOP_IDS}"
    IFS=';' read -ra WORKSHOP_IDS <<< "${SERVER_WORKSHOP_IDS}"
    for workshop_id in "${WORKSHOP_IDS[@]}"; do
        workshop_id="${workshop_id// /}"
        [[ -z "${workshop_id}" ]] && continue
        WORKSHOP_FLAGS+=(+workshop_download_item "${STEAM_APP_ID}" "${workshop_id}" validate)
    done
fi

steamcmd +force_install_dir "${STEAM_APP_DIR}" \
        +login anonymous \
        +app_update "${STEAM_APP_ID}" "${BETA_FLAG[@]}" validate \
        "${WORKSHOP_FLAGS[@]}" \
        +quit

bash "${SCRIPTS_DIR}/start.sh"
