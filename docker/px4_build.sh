xhost +local:root

# BUILD THE IMAGE
ROS_IMAGE="px4-jazzy"
docker build --network=host -f Dockerfile -t $ROS_IMAGE ./..
