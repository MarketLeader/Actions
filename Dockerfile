FROM tensorflow/tensorflow:latest-gpu
LABEL version=v1.0.9

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

ENV DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &>/dev/null
RUN apt-get install -y --no-install-recommends apt-utils &>/dev/null

ADD . /maps
ENTRYPOINT ["/maps/Scripts/entrypoint.sh"]
