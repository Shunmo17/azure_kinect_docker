## Description

This is Docker for Azure Kinect DK with ROS.

## Docker

### original image
ubuntu:18.04

### ros version

melodic

### installed tools
* iproute2
* iputils-ping
* net-tools
* terminator
* nautilus
* gedit
* usbutils



## Requirement

- PC with NVIDIA GPU

* nvidia-docker2

* Azure Kinect DK

  

## Usage

### Build

```
./build.sh
```



### Run

1. Set the ip address in `run.sh`

   CLIENT_IP：ip address of a PC connected to azure_kinect

   MASTER_IP：ip address of a PC running roscore

   ※If you use only one PC, please set both of them the same address.

2. ```
   ./run.sh
   ```
   If you run `./run.sh`, `packages/Azure_Kinect_ROS_Driver` will be mounted to the docker, and catkin build will be run automatically.


3. ```
   roslaunch azure_kinect_ros_driver azure_kinect.launch
   ```



## Author

[Shunmo17](https://github.com/Shunmo17)



## License

MIT
