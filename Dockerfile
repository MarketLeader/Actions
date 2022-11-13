FROM tensorflow/tensorflow:latest-gpu

LABEL version=v1.0.9

ENV DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND=noninteractive

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

RUN python3 -m pip install --user pipx
RUN python3 -m pipx ensurepath
RUN pipx install virtualenv /maps

ADD . /maps
RUN source /maps/bin/activate

ENV PATH="${PATH}:/maps/Scripts/"
ENTRYPOINT ["/maps/Scripts/entrypoint.sh"]
