############################################################
# Dockerfile that builds a ProjectZomboid server
############################################################
FROM cm2network/steamcmd:root

LABEL maintainer="self@danpock.me"

# Things that users should change...
ENV SERVER_NAME my-first-zomboid-server
ENV SERVER_DISPLAY_NAME 'My First Zomboid Server'
ENV SERVER_DESCRIPTION 'This is our project zomboid server for fun.'
ENV SERVER_PASSWORD ''
ENV SERVER_ADMIN_CLI_PASS 'letmein'
ENV SERVER_PUBLIC 0
ENV SERVER_UPNP 0
ENV SERVER_RCON_PORT 27015
ENV SERVER_RCON_PASSWORD ''
ENV SERVER_USER_COUNT 16
ENV SERVER_MODS ''
ENV SERVER_WORKSHOP_IDS ''
# End of things users should edit.
RUN export USER_PORT_START=$(expr 16261 + 1)
RUN export USER_PORT_END=$(expr 16261 + 1 + $SERVER_USER_COUNT)
RUN export USER_PORTS="${USER_PORT_START}-${USER_PORT_END}/udp"
RUN export SERVER_MODS="${SERVER_MODS}"
RUN export SERVER_WORKSHOP_IDS="${SERVER_WORKSHOP_IDS}"
# Steam things that shouldn't really be changed much...
ENV STEAM_APP_ID 380870
ENV STEAM_APP project-zomboid
ENV STEAM_APP_DIR "${HOMEDIR}/${STEAM_APP}-dedicated"
ENV SCRIPTS_DIR "${HOMEDIR}/scripts"
ENV SERVER_DATA_DIR "${HOMEDIR}/Zomboid"

RUN set -x \
	&& apt-get update \
	&& apt-get install -y libsdl2-2.0 vim \
	&& mkdir -p "${STEAM_APP_DIR}" "${SERVER_DATA_DIR}" \
	&& chmod 755 "${STEAM_APP_DIR}" "${SERVER_DATA_DIR}" \
	&& chown "${USER}:${USER}" "${STEAM_APP_DIR}" "${SERVER_DATA_DIR}" \
	&& rm -rf /var/lib/apt/lists/*

COPY scripts "${SCRIPTS_DIR}"
RUN set -x \
	&& chmod 755 "${SCRIPTS_DIR}" \
	&& chown "${USER}:${USER}" "${SCRIPTS_DIR}" \
	&& cd "$SCRIPTS_DIR" chmod +x  ./*.sh

USER ${USER}

WORKDIR ${HOMEDIR}

CMD ["bash", "scripts/entry.sh"]

# Expose ports
EXPOSE 8766/udp \
	8767/udp \
	16261/udp \
	"${USER_PORTS}" \
	"${SERVER_RCON_PORT}/tcp"
