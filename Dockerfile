FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        binutils build-essential sysstat strace software-properties-common && \
    add-apt-repository ppa:jonathonf/python-3.6 && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /work/
COPY . .

