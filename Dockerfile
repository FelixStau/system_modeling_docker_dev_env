FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

ARG SYSTEMC="systemc-2.3.3"
ARG SYSTEMC_HOME="/opt/${SYSTEMC}"
ARG VCML_HOME="/opt/vcml"
ARG VCML_BUILD_TYPE="RELEASE"
# ARG VCML_BUILD_TYPE="DEBUG"

RUN apt-get -qq update \
&& apt-get -qqy install \
    libboost-all-dev \
    build-essential \
    cmake \
    libelf-dev \
    git \
    software-properties-common \
    python3.7 python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install cpplint

WORKDIR /tmp
ADD http://www.accellera.org/images/downloads/standards/systemc/${SYSTEMC}.tar.gz ${SYSTEMC}.tar.gz
RUN tar -xzf ${SYSTEMC}.tar.gz && cd ${SYSTEMC} \
    && mkdir BUILD && cd BUILD \
    && ../configure --prefix=${SYSTEMC_HOME} --enable-static CXXFLAGS="-std=c++11" \
    && make -j 4 && make install \
    && cd ../.. \
    && rm -rf /tmp/*
ENV SYSTEMC_HOME ${SYSTEMC_HOME}


WORKDIR /tmp
ADD https://github.com/janweinstock/vcml/tarball/master vcml.tar
RUN tar -xzf vcml.tar && cd janweinstock-vcml-* \
    && mkdir -p BUILD/RELEASE && cd BUILD/RELEASE \
    && cmake -DCMAKE_INSTALL_PREFIX=${VCML_HOME} -DCMAKE_BUILD_TYPE=RELEASE ../.. \
    && make -j 4 && make install

RUN cd janweinstock-vcml-* \
    && mkdir -p BUILD/DEBUG && cd BUILD/DEBUG \
    && cmake -DCMAKE_INSTALL_PREFIX=/tmp/debug -DCMAKE_BUILD_TYPE=DEBUG ../.. \
    && make -j 4 && make install

RUN mv /tmp/debug/lib/libvcmld.a ${VCML_HOME}/lib/libvcmld.a
RUN rm -rf /tmp/*

ENV VCML_HOME ${VCML_HOME}

ENTRYPOINT /bin/bash
