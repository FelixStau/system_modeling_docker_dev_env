FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive
ENV SYSTEMC systemc-2.3.3

RUN apt-get -qq update \
&& apt-get -qqy install \
    libboost-all-dev \
    g++ \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN cd /opt \
    wget http://www.accellera.org/images/downloads/standards/systemc/$SYSTEMC.tar.gz \
    tar -xzf $SYSTEMC.tar.gz && cd $SYSTEMC \
    mkdir BUILD && cd BUILD \
    ../configure --enable-static CXXFLAGS="-std=c++11" \
    make -j 4 && make install \
    cd ../..\
    rm -rf $SYSTEMC.tar.gz $SYSTEMC/BUILD\

ENV SYSTEMC_HOME /opt/$SYSTEMC

ENTRYPOINT /bin/bash
