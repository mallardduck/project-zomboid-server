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

USER ${USER}

WORKDIR ${HOMEDIR}

COPY etc/entry.sh "${HOMEDIR}/entry.sh"

RUN set -x \
	&& apt-get update \
	&& apt-get install libsdl2-2.0 \
	&& mkdir -p "${STEAM_APP_DIR}" \
	&& chmod 755 "${HOMEDIR}/entry.sh" "${STEAM_APP_DIR}" \
	&& chown "${USER}:${USER}" "${HOMEDIR}/entry.sh" "${STEAM_APP_DIR}" \
	&& rm -rf /var/lib/apt/lists/*

CMD ["bash", "entry.sh"]

# Expose ports
EXPOSE 8766/udp \
	16261/tcp