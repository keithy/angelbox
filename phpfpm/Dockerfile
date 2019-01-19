# A generic DockerFile

ARG FROM
FROM ${FROM}

ARG FROM
ARG BUILDFILE=/build/Buildfile.sh
ARG UID=888

COPY root/. /

# Use a proper readable(?)/debuggable shell script.
RUN /bin/sh "${BUILDFILE}"  

USER ${UID}
	