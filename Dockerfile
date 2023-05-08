FROM runpod/pytorch:3.10-2.0.0-117

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /

# Update System Requirements
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends \
    wget \
    bash \
    openssh-server \
    software-properties-common

# Add deadsnakes repository for Python 3.8
RUN add-apt-repository ppa:deadsnakes/ppa

# Install Python 3.8 and related packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.8 \
    python3-pip \
    python3.8-distutils \
    python3.8-dev \
    python3.8-venv

RUN python3.8 -m venv /venv
ENV PATH=/venv/bin:$PATH

# Install system dependencies
RUN apt-get install python3-opencv -y

# Install Python dependencies (Worker Template)
COPY builder/requirements.txt /requirements.txt
RUN python3.8 -m pip install --upgrade pip==20.3 && \
    python3.8 -m pip install -r /requirements.txt && \
    rm /requirements.txt

ADD src .

ARG MODEL_TYPE="openpose"
ENV MODEL_TYPE=${MODEL_TYPE}

# Download weights
COPY builder/download_weights.py .
RUN python3.8 download_weights.py --model_type="${MODEL_TYPE}"
RUN rm download_weights.py

CMD python3.8 -u runpod_infer.py --model_type="${MODEL_TYPE}"
