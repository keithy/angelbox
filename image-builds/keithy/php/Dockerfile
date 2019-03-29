# A generic DockerFile

ARG FROM
FROM ${FROM}

ARG FROM
ARG BUILD_ENV=/build/default.env
ARG BUILD_SCRIPT=/build/default.sh
ARG BUILD_CONFIG=/build/config-default.sh
ARG UID=888
ARG USER=docker
ARG ROOT=root

USER 0
COPY ${ROOT}/. /

#true - to continue and create image for manual inspection and debugging
#exit - on error for CI builds
ARG ON_FAIL=exit

# Use a proper readable(?)/debuggable bash file!
RUN ${BUILD_SCRIPT} && /tests/success.sh || /tests/failed.sh && $ON_FAIL 99
    
USER ${UID}

#ENTRYPOINT ["sh", "/entrypoint.sh"]
	
