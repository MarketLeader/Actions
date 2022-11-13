# temp stage
FROM python:3.8-slim as builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install -r requirements.txt

# final stage
FROM tensorflow/tensorflow:latest-gpu

LABEL version=v1.0.9

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

ENV DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &>/dev/null
RUN apt-get install -qq --no-install-recommends apt-utils &>/dev/null

ADD . /maps
ENV PATH="/maps/bin:$PATH"
COPY --from=builder /opt/venv /maps

RUN source /maps/bin/activate
ENTRYPOINT ["/maps/Scripts/entrypoint.sh"]
