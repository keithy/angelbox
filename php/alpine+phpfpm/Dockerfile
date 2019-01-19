# A generic DockerFile

ARG FROM
FROM ${FROM}

ARG FROM
ARG BUILD_ENV=default.env
ARG BUILD_SCRIPT=default.sh
ARG BUILD_CLEAN=1
ARG UID=888
ARG USER=docker
ARG ROOT=root

COPY ${ROOT}/. /

# Use a proper readable(?)/debuggable bash file!
RUN /bin/sh "/build/${BUILD_SCRIPT}"

USER ${UID}
	