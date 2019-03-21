# A generic DockerFile

ARG FROM
FROM ${FROM}

ARG FROM
ARG BUILD_ENV=default.env
ARG BUILD_SCRIPT=default.sh
ARG BUILD_CONFIG=config-default.sh
ARG UID=888
ARG USER=docker
ARG ROOT=root

USER 0
COPY ${ROOT}/. /

# Use a proper readable(?)/debuggable bash file!
RUN /bin/sh "/build/start.sh" && echo "Success" || echo "Build Failed"

USER ${UID}

ENTRYPOINT ["sh", "/entrypoint.sh"]
# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
STOPSIGNAL SIGQUIT
	
