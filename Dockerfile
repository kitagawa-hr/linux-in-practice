FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        binutils build-essential sysstat strace \
    && rm -rf /var/lib/apt/lists/* && apt-get clean
WORKDIR /work/
COPY . .

