FROM debian:buster-slim
ENV DEBIAN_FRONTEND noninteractive

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y update && apt-get -y install \
	bc \
    build-essential \
    bzip2 \
	bzr \
	cmake \
	cmake-curses-gui \
	cpio \
	device-tree-compiler \
	git \
	imagemagick \
	libncurses5-dev \
	locales \
	make \
	p7zip-full \
	rsync \
	sharutils \
	scons \
	tree \
	unzip \
	vim \
	wget \
	zip \
	mc \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/workspace
WORKDIR /root

COPY support .
RUN ./build-toolchain.sh && rm -rf buildroot/output/build/* && rm -rf buildroot/output/dl/*
RUN cat ./setup-env.sh >> .bashrc


VOLUME /root/workspace
WORKDIR /root/workspace

CMD ["/bin/bash"]