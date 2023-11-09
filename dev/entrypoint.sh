#! /bin/bash

debug_message() {
    echo "\033[35m
        ____  __________  __  ________   __  _______  ____  ______
       / __ \/ ____/ __ )/ / / / ____/  /  |/  / __ \/ __ \/ ____/
      / / / / __/ / __  / / / / / __   / /|_/ / / / / / / / __/   
     / /_/ / /___/ /_/ / /_/ / /_/ /  / /  / / /_/ / /_/ / /___   
    /_____/_____/_____/\____/\____/  /_/  /_/\____/_____/_____/   
    
    "
    echo -e "\033[35mINFOt[AIRSIM]\tDEBUG_MODE IS SET. NOTHING WILL RUN"
}

if [ "${REBUILD_AIRSIM}" -eq "1" ]; then
    echo -e "\033[32mINFO\t[AIRSIM]\tREBUILD_AIRSIM SET AS 1. REBUILDING AIRSIM PLUGINS"
    echo -e "\033[32mINFO\t[AIRSIM]\tCLEANING UP PREVIOUS AIRSIM BUILD..."
    ${HOME}/AirSim/clean.sh > /dev/null
    echo -e "\033[32mINFO\t[AIRSIM]\tSTART REBUILDING AIRSIM PLUGIN..."
    ${HOME}/AirSim/build.sh
    echo -e "\033[32mINFO\t[AIRSIM]\tFINISHED BUILDING NEW AIRSIM PLUGIN\!"
fi

# A. DEBUG MODE / SIMULATION SELCTOR
## CASE A-1: DEBUG MODE
if [ "${DEBUG_MODE}" -eq "1" ]; then

    debug_message

    ## A-1. EXPORT ENVIRONMENT VARIABLE?
    ### CASE A-1-1: YES EXPORT THEM
    if [ "${EXPORT_ENV}" -eq "1" ]; then

        # PLACE YOUR ENVIRONMENT VARIABLE TO BE SET HERE
        # # - GET LINE NUMBER TO START ADDING export STATEMENT
        # COMMENT_BASH_START=$(grep -c "" /home/user/.bashrc)
        # COMMENT_ZSH_START=$(grep -c "" /home/user/.zshrc)

        # COMMENT_BASH_START=$(($COMMENT_BASH_START + 1))
        # COMMENT_ZSH_START=$(($COMMENT_ZSH_START + 1))


        # #- WTIE VARIABLED TO BE EXPORTED TO THE TEMPFILE
        # echo "DEBUG_MODE=0" >> /tmp/envvar
        # echo "GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}" >> /tmp/envvar

        # #- ADD VARIABLES TO BE EXPORTED TO SHELL RC
        # for value in $(cat /tmp/envvar)
        # do
        #     echo ${value} >> /home/user/.bashrc
        #     echo ${value} >> /home/user/.zshrc
        # done

        # #- ADD export STATEMENT TO VARIABLES
        # sed -i "${COMMENT_BASH_START},\$s/\(.*\)/export \1/g" \
        #     ${HOME}/.bashrc
        # sed -i "${COMMENT_ZSH_START},\$s/\(.*\)/export \1/g" \
        #     ${HOME}/.zshrc

        # #- REMOVE TEMPORARY FILE
        # rm -f /tmp/envvar

        echo "\033[31mINFO\t[AIRSIM]\tNO ENVIRONMENT VRIABLE TO BE SET."

    ### CASE A-1-2: NO LEAVE THEM CLEAN
    else
        echo "\033[32mINFO\t[AIRSIM]\tENVIRONMENT VARS WILL NOT BE SET."
    fi


## CASE A-2: SIMULATION MODE
else

    # PLACE YOUR AUTSTART SCRIPT HERE

    if [[ -z $(find ./binary -maxdepth 1 -name "*.sh") ]]; then
        echo -e "\033[31mINFO\t[AIRSIM]\tNO ANY SHELL SCRIPT EXIST"
        echo -e "\033[31mINFO\t[AIRSIM]\tTHERE IS NOTHING TO RUN\!"
    else
        echo -e "\033[32mINFO\t[AIRSIM] SHELL SCRIPT EXIST"
        echo -e "\033[32mINFO\t[AIRSIM] RUNNING SHELL SCRIPT\!"

        if [[ "${PIXELSTREAM}" -eq "1" ]]; then
            echo -e "\033[32mINFO\t[AIRSIM] PIXELSTREAM ENABLED\!"
            RUN_ARGUMENT="-RenderOffscreen -ForceRes -ResX=1920 -ResY=1080 -PixelStreamingIP=${CONTAINER_SIGNALING_ADDR} -PixelStreamingPort=8888"
        else
            echo -e "\033[32mINFO\t[AIRSIM] RUNNING ON X11\!"
            RUN_ARGUMENT="-Windowed"
        fi

        # if [ -f "./binary/log" ]; then
        #     rm -rf ./binary/log
        # fi

        touch /home/ue4/log

        eval $(find ./binary -maxdepth 1 -name "*.sh") ${RUN_ARGUMENT} > /home/ue4/log &
        while ! [[ $(cat /home/ue4/log) == *"Bringing up level for play took"* ]]; do
            echo -e "\033[31mINFO\t[AIRSIM]\tWAITING FOR AIRSIM TO STARTUP..."
            sleep 1s
        done
        sleep 2s

        echo -e "\033[32mINFO\t[AIRSIM] SIMULATION SUCCESSFULLY STARTED."
        echo -e "\033[32mINFO\t[AIRSIM] RUNNING AIRSIM ROS2 BRIDGE."
        
        source /opt/ros/galactic/setup.bash
        source /home/ue4/AirSim/ros2/install/setup.bash

        if [[ "${PIXELSTREAM}" -eq "1" ]]; then
            if [ -z ${CONTAINER_ROS2_AIRSIM_NAME} ]; then
                echo -e "\033[31mINFO\t[AIRSIM] CONTAINER_ROS2_AIRSIM_NAME IS NOT SET."
                exit 1
            else
                echo -e "\033[31mINFO\t[AIRSIM] PIXELSTREAM IS SET."
                echo -e "\033[31mINFO\t[AIRSIM] RUNNING EXTERNAL NODE BY DOCKER-OUT-OF-DOCKER..."
                docker exec -i ${CONTAINER_ROS2_AIRSIM_NAME} /home/user/scripts/run-airsim-ros2.sh
            fi
        else
            echo -e "\033[31mINFO\t[AIRSIM] PIXELSTREAM IS NOT SET."
            echo -e "\033[31mINFO\t[AIRSIM] RUNNING AIRSIM ROS2 NODE LOCALLY..."
            ros2 launch airsim_ros_pkgs airsim_node.launch.py
        fi
    fi
fi

# KEEP CONTAINER ALIVE
sleep infinity