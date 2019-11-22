## Description

Azure KinectをROS上で動かすためのDockerです。



## Docker

### original image
ubuntu:18.04

### ros version

melodic

### common tools
* iproute2
* iputils-ping
* net-tools
* terminator
* nautilus
* gedit
* usbutils



## Requirement

- NVIDIA GPUを搭載したPC

* nvidia-docker2

* Azure Kinect DK

  

## Usage

### Build

```
./build.sh
```



### Run

1. `run.sh`のIPアドレスを設定する

   CLIENT_IP：azure_kinectを接続するPCのIPアドレス

   MASTER_IP：roscoreを動かすPCのIPアドレス

   ※1台のPCのみ使用する場合は、両方とも同じIPアドレスで設定

2. ```
   ./run.sh
   ```

   ./run.shをすると、`packages/Azure_Kinect_ROS_Driver`のROSパッケージがマウントされ、自動的にbuildされます。


3. ```
   roslaunch azure_kinect_ros_driver azure_kinect.launch
   ```



## Author

[Shunmo17](https://github.com/Shunmo17)



## License

MIT