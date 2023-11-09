# CONTAINERIZED AIRSIM FOR PX4 SITL

## 0. OVERVIEW

- This repository contains resources for building an AirSim container for running PX4 Autopilot SITL.
- AirSim does not support recent versions of Ubuntu newer than 20.04 Focal Fossa.
- Applications packed as Docker containers can help overcome this issue.
- The container built from this repository also contains [GazeboDrone](https://microsoft.github.io/AirSim/gazebo_drone/) for integrating Gazebo Simulation.
- A prebuilt image is available on [Docker Hub](https://hub.docker.com/r/kestr3l/airsim).


## 1. AVAILABLE TAGS & BUILD ORDERS

### 1.1. TAG NAMING RULES

|TAG|DESCRIPTION|Example|Misc.|
|:-|:-|:-|:-|
|TBD||||

### 1.2. IMAGE AVAILABILITY

|TAG|ARCH|AVAILABILITY|Misc.|
|:-|:-|:-:|:-|
|TBD||||

### 1.3. BUILD ORDERS

```
TBD
```


## 2. ENVIRONMENT VARIABLE & VOLUME/DEVICE MAPPING SETUPS

### 2.1. ENVIRONMENT VARIABLE SETTINGS LIST

|VAR|DESCRIPTION|EXAMPLE|Misc.|
|:-|:-|:-|:-|
|TBD||||

### 2.2. VOLUME MAPPING SETTINGS LIST

|CONTAINER DIR|DESCRIPTION|HOST DIR EXAMPLE|Misc.|
|:-|:-|:-|:-|
|TBD||||

### 2.3. DEVICE MAPPING SETTINGS LIST

|DEVICE|DESCRIPTION|EXAMPLE|Misc.|
|:-|:-|:-|:-|
|TBD||||

## 3. HOW-TO-BUILD

```shell
TBD
```

## 4. ATTACHING CONTAINER TO SITL

### 4.1. RUN BY `docker compose` COMMAND

- Since there are many modular containers required to run PX4 SITL, deployment using `docker-compose` is recommended.
- The configuration of `docker-compose.yml` will vary based on the user's needs.
- In this document, a snippet for adding an AirSim deployment to `docker-compose.yml` is suggested:

```yaml
TBD
``````

### 4.2. RUN BY `docker run` COMMAND (NOT RECOMMENDED)

> This container is designed to be deployed simultaneously with other SITL components using the `docker-compose` command.
> Running it with the `docker run` command is only recommended for unit testing or debugging purposes.

```shell
TBD
```