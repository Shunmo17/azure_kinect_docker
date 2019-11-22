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
COPY ./packages/ros_entrypoint.sh /

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
COPY ./packages/catkin_build.bash /
RUN	/bin/bash -c "source /opt/ros/melodic/setup.bash; catkin init" && \
    echo "source /home/catkin_ws/devel/setup.bash" >> ~/.bashrc && \
    echo "source /catkin_build.bash" >> ~/.bashrc

##############################################################################
##                                 for GUI                                  ##
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
# register Microsoft repository
RUN apt install -y curl software-properties-common
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN apt-get update
RUN apt-add-repository https://packages.microsoft.com/ubuntu/18.04/prod

# prepare
RUN apt-get update && apt-get install -y expect
COPY ./packages/install_azure_kinect_sdk.sh /install_azure_kinect_sdk.sh

# install azure kinect sdk
RUN /install_azure_kinect_sdk.sh

##############################################################################
##                             terminal setting                             ##
##############################################################################

RUN echo "export PS1='\[\e[1;33;40m\]DOCKER AZURE_KINECT\[\e[0m\] \u:\w\$ '">> ~/.bashrc

##############################################################################
##                            setting ros master                            ##
##############################################################################
# ROS MATER setting
ENV CLIENT_IP 192.168.1.221
ENV MASTER_IP 192.168.1.200

RUN echo 'export ROS_IP=${CLIENT_IP}' >> ~/.bashrc && \
    echo 'export ROS_MASTER_URI=http://${MASTER_IP}:11311' >> ~/.bashrc