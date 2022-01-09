############################################################
# Dockerfile that builds a ProjectZomboid server
############################################################
FROM cm2network/steamcmd:root

LABEL maintainer="self@danpock.me"

ENV SERVER_NAME my-first-zomboid-server
ENV SERVER_PORT 16261
ENV STEAM_APP_ID 380870
ENV STEAM_APP project-zomboid
ENV STEAM_APP_DIR "${HOMEDIR}/${STEAM_APP}-dedicated"

COPY etc/entry.sh "${HOMEDIR}/entry.sh"

RUN set -x \
	&& apt-get update \
	&& apt-get install -y libsdl2-2.0 \
	&& mkdir -p "${STEAM_APP_DIR}" "${HOMEDIR}/Zomboid/" \
	&& chmod 755 "${HOMEDIR}/entry.sh" "${STEAM_APP_DIR}" "${HOMEDIR}/Zomboid/" \
	&& chown "${USER}:${USER}" "${HOMEDIR}/entry.sh" "${STEAM_APP_DIR}" "${HOMEDIR}/Zomboid/" \
	&& rm -rf /var/lib/apt/lists/*

USER ${USER}

WORKDIR ${HOMEDIR}

CMD ["bash", "entry.sh"]

# Expose ports
EXPOSE 8766/udp \
	16261/tcp
