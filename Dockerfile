#·Composing IMG DDK build environment
FROM ubuntu:20.04
LABEL maintainer="andrei.mironenko@gmail.com"
ENV REFRESHED_AT 2023-04-17
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

ARG uid
ARG gid
ARG username

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install apt-utils
# Set locales to en_US.UTF-8

RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8

RUN apt-get -y install vim
RUN apt-get -y install nano
RUN apt-get -y install rsync
RUN apt-get -y install zip
RUN apt-get -y install tree

RUN apt-get -y install ninja-build
RUN apt-get -y install build-essential
RUN apt-get -y install bison flex gawk gcc g++ llvm m4 patch
RUN apt-get -y install make ninja-build pkg-config tar zip
RUN apt-get -y install automake bc dpkg-dev libelf-dev libncurses5-dev
RUN apt-get -y install libssl-dev  perl texinfo
RUN apt-get -y install wget xutils-dev

RUN apt-get -y install libdrm-dev libunwind-dev zlib1g-dev
RUN apt-get -y install autopoint gettext gperf intltool libglib2.0-dev
RUN apt-get -y install libltdl-dev libtool 
RUN apt-get -y install git
RUN apt-get -y install xfonts-utils xsltproc x11-xkb-utils
RUN apt-get -y install gcc-multilib g++-multilib
RUN apt-get -y install clang
RUN apt-get -y install libclang1 

# Install python2
#RUN apt-get -y install python2-libxml2 python2-mako python2-pip python2-git python2-clang
RUN apt-get -y install python 
#RUN apt-get -y install python-is-python3

# Graphics related packages
#RUN pip3 install  --trusted-host pypi.org  --trusted-host files.pythonhosted.org meson
#RUN apt-get -y install libxinerama-dev libxcursor-dev xorg-dev libglu1-mesa-dev pkg-config
#RUN apt-get -y install libxrandr-dev libxi-dev
#RUN apt-get -y install mesa-common-dev opencl-headers

RUN apt-get -y install iputils-ping

RUN apt-get -y install openssh-server openssh-client openssl
RUN apt-get -y install  net-tools iproute2

RUN apt-get -y install openjdk-11-jdk
RUN apt-get -y install screen
RUN apt-get -y install tmux

RUN apt-get -y install libstb-dev
RUN apt-get -y install curl

RUN apt-get -y install expect
RUN apt-get -y install indent
RUN apt-get -y install gpg ca-certificates wget

# Packages required by Ycto
RUN apt-get -y install chrpath cpio diffstat liblz4-tool pigz zstd
RUN apt-get -y install git-lfs gfortran 

# Create a non-root user with the same UID/GID as the host user
RUN groupadd -g ${gid} ${username}
RUN useradd -l -u ${uid} -g ${gid} -m ${username}

RUN sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking accept-new/' /etc/ssh/ssh_config

#RUN echo "check_certificate = off" >> /home/${username}/.wgetrc
#RUN chown ${username}:${username} /home/${username}/.wgetrc

# install Ubuntu target linux-headers package which is required for build kernel module in a container
#RUN apt-get -y install linux-headers-${kernel_id}

# setting repository for getting vulkan-sdk
# RUN wget -qO - http://packages.lunarg.com/lunarg-signing-key-pub.asc | apt-key add -
# RUN wget -qO /etc/apt/sources.list.d/lunarg-vulkan-focal.list http://packages.lunarg.com/vulkan/lunarg-vulkan-focal.list

# setting repository for getting latest version of the CMake
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null

RUN apt-get -y update
# RUN apt-get -y install vulkan-sdk
RUN apt-get -y upgrade cmake

# Change from Ubuntu default dash shell to bash
RUN ln -sf bash /bin/sh

# install vcpkg
ENV appsdir="/opt/apps"
ENV vcpkgdir="${appsdir}/vcpkg"
ENV repodir="${appsdir}/repo"
RUN mkdir -p ${appsdir} 
RUN chown ${username}:${username} ${appsdir} 
RUN awk -v path="${vcpkgdir}" -F= -i inplace '/^PATH/ { gsub(/"/, "", $2); print $1 FS "\"" $2 ":" path "\""; next } 1' /etc/environment
RUN awk -v path="${repodir}" -F= -i inplace '/^PATH/ { gsub(/"/, "", $2); print $1 FS "\"" $2 ":" path "\""; next } 1' /etc/environment

# Start SSH server
EXPOSE 22

USER ${username}
RUN git clone https://github.com/Microsoft/vcpkg.git ${vcpkgdir} 
RUN /opt/apps/vcpkg/bootstrap-vcpkg.sh

RUN git clone https://gerrit.googlesource.com/git-repo ${repodir}

USER root
WORKDIR /home/${username}
CMD /etc/init.d/ssh start && /bin/bash