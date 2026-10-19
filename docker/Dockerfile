FROM osrf/ros:jazzy-desktop-full

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive

# Optional: used when running with NVIDIA Container Toolkit.
ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute,display

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        bash-completion \
        ca-certificates \
        python3-colcon-common-extensions \
    && rm -rf /var/lib/apt/lists/*

# Both repositories track main here.
# For reproducible builds, pin compatible PX4 and px4_msgs revisions.
ARG PX4_BRANCH=main
ARG PX4_MSGS_BRANCH=main

USER ubuntu

WORKDIR /home/ubuntu/px4

RUN git clone https://github.com/PX4/PX4-Autopilot.git --recursive

WORKDIR /home/ubuntu/px4/PX4-Autopilot

USER root

RUN RUNS_IN_DOCKER=true /bin/bash Tools/setup/ubuntu.sh --no-nuttx \
    && rm -rf /var/lib/apt/lists/*

# Compile SITL during image construction.
USER ubuntu
RUN make px4_sitl

WORKDIR /home/ubuntu/px4/ros2_px4_ws/src

RUN git clone https://github.com/PX4/px4_msgs.git \
    && git clone --branch v2.4.3 \
        https://github.com/eProsima/Micro-XRCE-DDS-Agent.git

WORKDIR /home/ubuntu/px4/ros2_px4_ws

RUN /bin/bash -c '. /opt/ros/jazzy/setup.bash && colcon build --symlink-install'

# Convenience for interactive bash sessions.
RUN echo 'source /opt/ros/jazzy/setup.bash' >> /home/ubuntu/.bashrc \
    && echo 'source /home/ubuntu/px4/ros2_px4_ws/install/setup.bash' >> /home/ubuntu/.bashrc

WORKDIR /home/ubuntu/px4/PX4-Autopilot

CMD ["bash"]
