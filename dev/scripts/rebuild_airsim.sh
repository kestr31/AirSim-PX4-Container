#! /bin/bash

echo -e "\033[32mINFO\t[AIRSIM]\tREBUILD_AIRSIM SET AS 1. REBUILDING AIRSIM PLUGINS"

echo -e "\033[32mINFO\t[AIRSIM]\tCLEANING UP PREVIOUS AIRSIM BUILD..."
${HOME}/AirSim/clean.sh > /dev/null

echo -e "\033[32mINFO\t[AIRSIM]\tSTART REBUILDING AIRSIM PLUGIN..."
${HOME}/AirSim/build.sh

echo -e "\033[32mINFO\t[AIRSIM]\tFINISHED BUILDING NEW AIRSIM PLUGIN\!"