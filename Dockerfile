FROM tensorflow/tensorflow:latest-gpu

LABEL version=v1.0.9
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

ENV DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &>/dev/null
RUN apt-get install python3.8-venv &>/dev/null

RUN python3.8 -m venv /maps
ENV PATH="/maps/bin:${PATH}"

ADD . /maps
RUN chown -R root:root /maps

RUN source /maps/bin/activate
ENTRYPOINT ["/maps/Scripts/entrypoint.sh"]
