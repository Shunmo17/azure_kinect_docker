# The MIT License (MIT)

# Copyright (c) 2019 Shunmo17

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


##############################################################################
##                             plain ubuntu 18.04                           ##
##############################################################################
# original image
FROM ubuntu:18.04

# change server for apt-get
RUN sed -i 's@archive.ubuntu.com@ftp.jaist.ac.jp/pub/Linux@g' /etc/apt/sources.list

# avoid time-zone setting
RUN apt-get update \
  && apt-get install -y tzdata

##############################################################################
##                     ROS melodic-Desktop-Full Install                     ##
##############################################################################
# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros1-latest.list

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
ENV ROS_DISTRO melodic
RUN apt-get update && apt-get install -y \
    ros-melodic-desktop-full \
    && rm -rf /var/lib/apt/lists/*

# setup entrypoint
COPY ./include/ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

##############################################################################
##                              ros initialize                              ##
##############################################################################

RUN mkdir -p /home/catkin_ws/src

# for catkin build
RUN apt-get update && apt-get install -y \
    python-catkin-tools

WORKDIR /home/catkin_ws
COPY ./include/catkin_build.bash /
RUN	/bin/bash -c "source /opt/ros/melodic/setup.bash; catkin init" && \
    echo "source /home/catkin_ws/devel/setup.bash" >> ~/.bashrc && \
    echo "source /catkin_build.bash" >> ~/.bashrc

##############################################################################
##                          for using nvidia gpu                            ##
##############################################################################
RUN apt-get update && apt-get install -y --no-install-recommends \
        pkg-config \
        libxau-dev \
        libxdmcp-dev \
        libxcb1-dev \
        libxext-dev \
        libx11-dev && \
    rm -rf /var/lib/apt/lists/*

COPY --from=nvidia/opengl:1.0-glvnd-runtime-ubuntu16.04 \
  /usr/local/lib/x86_64-linux-gnu \
  /usr/local/lib/x86_64-linux-gnu

COPY --from=nvidia/opengl:1.0-glvnd-runtime-ubuntu16.04 \
  /usr/local/share/glvnd/egl_vendor.d/10_nvidia.json \
  /usr/local/share/glvnd/egl_vendor.d/10_nvidia.json

RUN echo '/usr/local/lib/x86_64-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    ldconfig && \
    echo '/usr/local/$LIB/libGL.so.1' >> /etc/ld.so.preload && \
    echo '/usr/local/$LIB/libEGL.so.1' >> /etc/ld.so.preload

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics


##############################################################################
##                                  common                                  ##
##############################################################################
# install ifconfig & ping
RUN apt-get update && apt-get install -y \
    iproute2 \
    iputils-ping \
    net-tools \
    terminator \
    nautilus \
    gedit \
    usbutils

##############################################################################
##                           azure kinect install                           ##
##############################################################################
# azure kinect
## register Microsoft repository
RUN apt update && apt install -y \
    curl \
    software-properties-common
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN apt update
RUN apt-add-repository https://packages.microsoft.com/ubuntu/18.04/prod

RUN apt update && apt install -y \
    ninja-build \
    doxygen \
    clang \
    gcc-multilib-arm-linux-gnueabihf \
    g++-multilib-arm-linux-gnueabihf && \
   rm -rf /var/lib/apt/lists/*

RUN apt update && apt install -y \
    freeglut3-dev \
    libgl1-mesa-dev \
    mesa-common-dev \
    libsoundio-dev \
    libvulkan-dev \
    libxcursor-dev \
    libxinerama-dev \
    libxrandr-dev \
    uuid-dev \
    libsdl2-dev \
    usbutils \
    libusb-1.0-0-dev \
    openssl \
    libssl-dev \
    wget \
    git  && \
    rm -rf /var/lib/apt/lists/*

# update cmake
WORKDIR /
RUN wget https://cmake.org/files/v3.16/cmake-3.16.5.tar.gz  -O cmake-3.16.5.tar.gz
RUN tar -zxvf cmake-3.16.5.tar.gz
WORKDIR /cmake-3.16.5

RUN ./bootstrap
RUN make
RUN make install

RUN apt update && apt install -y \
    g++ \
    perl

# install azure kinect sdk
WORKDIR /
RUN apt-get update && apt-get install -y \
    zip \
    unzip && \
   rm -rf /var/lib/apt/lists/*
RUN wget https://www.nuget.org/api/v2/package/Microsoft.Azure.Kinect.Sensor/1.4.0 -O microsoft.azure.kinect.sensor.1.4.0.nupkg
RUN mv microsoft.azure.kinect.sensor.1.4.0.nupkg  microsoft.azure.kinect.sensor.1.4.0.zip
RUN unzip -d microsoft.azure.kinect.sensor.1.4.0 microsoft.azure.kinect.sensor.1.4.0.zip


WORKDIR /home

RUN git clone https://github.com/microsoft/Azure-Kinect-Sensor-SDK.git
RUN mkdir -p /home/Azure-Kinect-Sensor-SDK/build/bin/
RUN cp /microsoft.azure.kinect.sensor.1.4.0/linux/lib/native/x64/release/libdepthengine.so.2.0 /home/Azure-Kinect-Sensor-SDK/build/bin/libdepthengine.so.2.0
RUN cp /microsoft.azure.kinect.sensor.1.4.0/linux/lib/native/x64/release/libdepthengine.so.2.0 /lib/x86_64-linux-gnu/
RUN cp /microsoft.azure.kinect.sensor.1.4.0/linux/lib/native/x64/release/libdepthengine.so.2.0 /usr/lib/x86_64-linux-gnu/
RUN chmod a+rwx /usr/lib/x86_64-linux-gnu
RUN chmod a+rwx -R /lib/x86_64-linux-gnu/
RUN chmod a+rwx -R /home/Azure-Kinect-Sensor-SDK/build/bin/

RUN cd /home/Azure-Kinect-Sensor-SDK &&\
    mkdir -p build && \
    cd build &&\
    cmake .. -GNinja &&\
    ninja &&\
    ninja install

RUN mkdir -p /etc/udev/rules.d/
RUN cp /home/Azure-Kinect-Sensor-SDK/scripts/99-k4a.rules /etc/udev/rules.d/99-k4a.rules
RUN chmod a+rwx /etc/udev/rules.d

##############################################################################
##                             terminal setting                             ##
##############################################################################

RUN echo "export PS1='\[\e[1;33;40m\]AZURE_KINECT\[\e[0m\] \u:\w\$ '">> ~/.bashrc
