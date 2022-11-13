# temp stage
FROM python:3.8-slim as builder

LABEL version=v1.0.9

ENV DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &>/dev/null
RUN apt-get install -y --no-install-recommends gcc &>/dev/null

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN python -m venv /maps
ENV PATH="/maps/bin:$PATH"

COPY requirements.txt .
ENV PIP_CACHE_DIR=vendor/bundle/pip

RUN python -m pip install --upgrade pip setuptools six wheel &>/dev/null
RUN python -m pip install pytest-cov -r requirements.txt &>/dev/null

# final stage
FROM tensorflow/tensorflow:latest-gpu

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

ENV DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &>/dev/null
RUN apt-get install -y --no-install-recommends apt-utils &>/dev/null

ADD . /maps
COPY --from=builder /maps /maps

ENV PATH="/maps/bin:$PATH"
RUN source /maps/bin/activate

ENTRYPOINT ["/maps/Scripts/entrypoint.sh"]
