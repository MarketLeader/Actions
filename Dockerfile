# temp stage
FROM python:3.8-slim as builder

WORKDIR /app
LABEL version=v1.0.9

ENV DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &>/dev/null
RUN apt-get install -y --no-install-recommends gcc &>/dev/null

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN python -m pip install --upgrade pip setuptools six wheel &>/dev/null
RUN pip install pytest-cov -r requirements.txt &>/dev/null

# final stage
FROM tensorflow/tensorflow:latest-gpu

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

ENV DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &>/dev/null
RUN apt-get install -y --no-install-recommends apt-utils &>/dev/null

ADD . /maps
COPY --from=builder /opt/venv /maps

ENV PATH="/maps/bin:$PATH"
ENTRYPOINT ["/maps/Scripts/entrypoint.sh"]
