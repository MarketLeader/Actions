FROM tensorflow/tensorflow:latest-gpu

LABEL version=v1.0.9
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

ENV DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND=noninteractive
ENV PATH="${PATH}:/root/.local/bin"

RUN python3 -m pip install --user pipx
RUN python3 -m pipx ensurepath
RUN pipx install virtualenv
RUN python3 -m virtualenv /maps

ADD . /maps
RUN source /maps/bin/activate
ENTRYPOINT ["/maps/Scripts/entrypoint.sh"]
