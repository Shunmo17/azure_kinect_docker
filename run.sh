#!/bin/sh

xhost +local:user
docker run -it \
    --runtime=nvidia \
    --rm \
    --env="DISPLAY" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --env="QT_X11_NO_MITSHM=1" \
    --name azure_kinect \
    --net host \
    --privileged \
    --env CLIENT_IP=192.168.1.55 \
    --env MASTER_IP=192.168.1.55 \
    -v "/etc/localtime:/etc/localtime:ro" \
    -v "/$(pwd)/packages/Azure_Kinect_ROS_Driver:/home/catkin_ws/src/Azure_Kinect_ROS_Driver" \
    -v "/$(pwd)/startup/startup.sh:/startup.sh" \
    azure_kinect:latest
