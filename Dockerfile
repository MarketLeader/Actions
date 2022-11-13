FROM tensorflow/tensorflow:latest-gpu
LABEL version=v0.0.5

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

ENV DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &>/dev/null 
RUN apt-get install -y --no-install-recommends \
 apt-utils build-essential gcc gfortran libopenblas-dev \
 ffmpeg libsm6 libxext6 python3.8-venv &>/dev/null

RUN apt-get clean &>/dev/null 
RUN rm -rf /var/lib/apt/lists/* &>/dev/null

ADD . /maps
ENTRYPOINT ["/maps/Scripts/entrypoint.sh"]
