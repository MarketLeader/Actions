# temp stage
FROM tensorflow/tensorflow:latest-gpu

LABEL version=v1.0.9

ENV DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND=noninteractive

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

RUN apt-get update &>/dev/null
RUN apt-get install -y --no-install-recommends gcc &>/dev/null

RUN apt-get install python3.8-venv &>/dev/null
RUN python3.8 -m venv /maps

ADD . /maps
ENV PATH="/maps/bin:$PATH"

RUN source /maps/bin/activate
ENTRYPOINT ["/maps/Scripts/entrypoint.sh"]
