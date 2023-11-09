ARG BASEIMAGE
ARG BASETAG

#          __                                     __ 
#    _____/ /_____ _____ ____        ____ _____  / /_
#   / ___/ __/ __ `/ __ `/ _ \______/ __ `/ __ \/ __/
#  (__  ) /_/ /_/ / /_/ /  __/_____/ /_/ / /_/ / /_  
# /____/\__/\__,_/\__, /\___/      \__,_/ .___/\__/  
#                /____/                /_/           

# BASE STAGE FOR CACHINE APT PACKAGE LISTS
FROM ubuntu:20.04 as stage_apt

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BASETAG

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

USER root
WORKDIR /

# SET KAKAO MIRROR FOR FASTER BUILD
# THIS WILL ONLY BE APPLIED ON THE BUILD PROCESS
RUN \
    rm -rf /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
	&& sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list \
    && apt-get update

# INSTALL DEPENDENCIES FOR ADDING ADDITIONAL REPOS.
RUN \
    apt install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common \
        wget

# ADD ROS2 PACKAGE REPOSITORY
RUN \
    add-apt-repository universe \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && apt-get update

# ADD DOCKER PACKAGE REPOSITORY 
RUN \
    install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update


#          __                         _____             __
#    _____/ /_____ _____ ____        / __(_)___  ____ _/ /
#   / ___/ __/ __ `/ __ `/ _ \______/ /_/ / __ \/ __ `/ / 
#  (__  ) /_/ /_/ / /_/ /  __/_____/ __/ / / / / /_/ / /  
# /____/\__/\__,_/\__, /\___/     /_/ /_/_/ /_/\__,_/_/   
#                /____/    

FROM ${BASEIMAGE}:${BASETAG} as stage_final

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BUILD_VARIANT

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

USER root
WORKDIR /

# INSTAL BASIC DEPENDENCIES
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
    --mount=type=cache,target=/etc/apt/sources.list,from=stage_apt,source=/etc/apt/sources.list \
	apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        git \
        locales \
        sudo \
        tzdata \
    && rm -rf /tmp/*

# SET LOCALE TO en_UT.UTF-8
RUN \
    locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# COPY LIST OF APT DEPENDENCIES TO BE INSTALLED
COPY dev/aptDeps.txt /tmp/aptDeps.txt

# INSTALL PACKAGES AVAIABLE BY APT REPOSITORY
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
    --mount=type=cache,target=/etc/apt/sources.list,from=stage_apt,source=/etc/apt/sources.list \
	if [[ "x${BUILD_VARIANT}" == "xgzdrone" ]]; then \
        echo -e "\nlibgazebo11-dev" >> /tmp/aptDeps.txt; \
    fi \
    && apt-get install --no-install-recommends -y \
        $(cat /tmp/aptDeps.txt) \
    && rm -rf /tmp/*

# ADD NON-ROOT USER user AND GRANT SUDO PERMISSION
# THIS IS BAD FOR CONTAINER SECURITY
# BUT THIS DOES NOT MATTERS FOR DEVELOPING SIMULATOR CONTAINER
RUN \
    echo "ue4 ALL=NOPASSWD: ALL" >> /etc/sudoers \
    && usermod -aG docker ue4

# CHANGE USER TO ue4
USER ue4
WORKDIR /home/ue4

# COPY AIRSIM MODELS
COPY --chown=ue4:ue4 \
    models/typhoon_h480/include /tmp/models/typhoon_h480/include
COPY --chown=ue4:ue4 \
    models/typhoon_h480/TyphoonH480.json \
    /home/ue4/Documents/AirSim/settings.json

# INSTALL AIRSIM DEPENDENCIES AND BUILD
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
    --mount=type=cache,target=/etc/apt/sources.list,from=stage_apt,source=/etc/apt/sources.list \
    git clone https://github.com/microsoft/AirSim.git -b v1.8.1 ${HOME}/AirSim \
    && cp -r /tmp/models/typhoon_h480/include ${HOME}/AirSim/AirLib \
    && sed -i \
        "$(grep -wn 'apt-get update' ./AirSim/setup.sh | cut -d: -f1 | head -1) s/^/#/" \
        ${HOME}/AirSim/setup.sh \
	&& ${HOME}/AirSim/setup.sh \
    && if [[ "x${BUILD_VARIANT}" == "xgzdrone" ]]; then \
        ${HOME}/AirSim/build.sh --gcc; \
    else \
        ${HOME}/AirSim/build.sh; \
    fi \
    && rm -rf /tmp/*


# COPY MODIFIED GAZEBODRONE SOURCE CODE SNIPPET
## THIS ENABLES GAZEBODRONE TO ACCEPT ENVIROMENT VARIABLES
COPY --chown=ue4:ue4 \
    dev/gazeboDrone.cpp /home/ue4/AirSim/GazeboDrone/src/gazeboDrone.cpp

# MODIFY GAZEBODRONE SOURCE CODE AND BUILD
RUN \
    sed -i "42d" \
        ${HOME}/AirSim/GazeboDrone/src/main.cpp \
    && sed -i '41i\\' \
        ${HOME}/AirSim/GazeboDrone/src/main.cpp \
    && sed -i "41r ${HOME}/AirSim/GazeboDrone/src/gazeboDrone.cpp" \
        ${HOME}/AirSim/GazeboDrone/src/main.cpp \
    && rm -rf ${HOME}/AirSim/GazeboDrone/src/gazeboDrone.cpp \
    && if [[ "x${BUILD_VARIANT}" == "xgzdrone" ]]; then \
        mkdir ${HOME}/AirSim/GazeboDrone/build \
        && cmake \
            -B ${HOME}/AirSim/GazeboDrone/build \
            -S ${HOME}/AirSim/GazeboDrone \
            -D CMAKE_C_COMPILER=gcc-8 \
            -D CMAKE_CXX_COMPILER=g++-8 \
        && make -j$(nproc) -C \
            ${HOME}/AirSim/GazeboDrone/build; \
    fi

# COPY PYTHON DEPENDENCIES LIST
COPY --chown=ue4:ue4 \
    dev/pyDeps.txt /tmp/pyDeps.txt

# INSTALL PYTHON DEPENDENCIES
# AIRSIM PACKAGE MUST BE INSTALLED LATER THAN MSGPACK-RPC-PYTHON
RUN \
    python3 -m pip install \
        $(sed '$d' /tmp/pyDeps.txt) \
    && python3 -m pip install \
        $(sed '$!d' /tmp/pyDeps.txt) \
    && rm -rf /tmp/*

# MOVE TO AIRSIM ROS2 PACKAGE DIRECTORY
WORKDIR /home/ue4/AirSim/ros2

# BUILD AIRSIM ROS2 PACKAGE
RUN \
    source /opt/ros/galactic/setup.bash \
    && colcon build \
        --cmake-args -DCMAKE_C_COMPILER=gcc-8 \
		--cmake-args -DCMAKE_CXX_COMPILER=g++-8 \
		--cmake-args -DCMAKE_BUILD_TYPE=Debug

# GO BACK TO HOME DIRECTORY
WORKDIR /home/ue4

# ENTRYPOINT SCRIPT
# SET PERMISSION SO THAT USER CAN EDIT INSIDE THE CONTAINER
COPY --chown=ue4:ue4 \
    dev/entrypoint.sh \
    /usr/local/bin/entrypoint.sh

# CREATE SYMBOLIC LINK FOR QUICK ACCESS
# THEN ADD ADDITIONAL LINES ON SHELL RC FOR ROS2 USAGE
RUN \
    mkdir /home/ue4/scripts \
    && sudo ln -s /usr/local/bin/entrypoint.sh /home/ue4/scripts/entrypoint.sh \
    && echo "source /opt/ros/galactic/setup.bash" >> ${HOME}/.bashrc \
    && echo "source ${HOME}/AirSim/ros2/install/setup.bash" >> ${HOME}/.bashrc

CMD [ "/usr/local/bin/entrypoint.sh" ]

#
# docker run -it --rm --gpus=all \
# -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
# -v /run/user/$UID/pulse:/run/user/1000/pulse \
# -v <YOUR_DIRECTORY_TO_UE_BINARY>:/home/ue4/binary \
# -e DISPLAY \
# kestr3l/airsim:dev-1.8.1 bash

# ------ BUILD COMMAND(base) ------
# DOCKER_BUILDKIT=1 docker build \
# --build-arg BASEIMAGE=adamrehn/ue4-runtime \
# --build-arg BASETAG=20.04-cudagl11-x11 \
# -t kestr3l/airsim:dev-1.8.1 \
# -f ./Dockerfile ../

# ------ BUILD COMMAND(gzdrone) ------
# DOCKER_BUILDKIT=1 docker build \
# --build-arg BASEIMAGE=adamrehn/ue4-runtime \
# --build-arg BASETAG=20.04-cudagl11-x11 \
# --build-arg BUILD_VARIANT=gzdrone \
# -t kestr3l/airsim:dev-1.8.1-gzdrone \
# -f ./Dockerfile ../