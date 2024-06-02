#!/bin/bash
# Description: tutorial del curso de introducción a linux de hack4u

# color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[0;37m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
TURQUOISE='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# ctrl + c
trap ctrl_c INT

function ctrl_c(){
    echo -e "\n${RED}Saliendo...${NC}\n"
}

# help
function help(){
    echo -e "\n${GREEN}Uso:${NC} htbmachines.sh [opciones]\n"
}

# search machine
function search_machine(){
    machine_name=$1
    echo -e "\n${GREEN}Buscando máquina...${NC}\n"
    echo -e "${YELLOW}Máquina:${NC} $machine_name\n"
}

declare -i parameter_counter=0

# menu
while getopts "m:h" arg; do
    case $arg in
        m) machine_name=$OPTARG; let parameter_counter+=1;;

        h) ;;
    esac
done

if [ $parameter_counter -eq 1 ]; then
    search_machine $machine_name
else
    help
fi
