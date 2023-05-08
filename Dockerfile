FROM runpod/pytorch:3.10-2.0.0-117

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /

# Update System Requirements
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends\
    wget\
    bash\
    openssh-server &&\
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Install Python 3.8
RUN apt remove python3-apt -y
RUN apt-get update && apt-get install -y --no-install-recommends
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install python3.8 -y
RUN apt-get install python3-pip -y
RUN apt-get install python3.8-distutils -y

RUN apt-get install python3.8-dev -y
RUN apt-get install python3.8-venv -y
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
