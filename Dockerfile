FROM runpod/pytorch:3.10-2.0.0-117

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /

# Install Python 3.8
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

RUN python3.8 download_weights.py --model_type="${MODEL_TYPE}"

CMD python3.8 -u runpod_infer.py --model_type="${MODEL_TYPE}"
