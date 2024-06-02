#!/bin/bash
# Description: tutorial del curso de introducción a linux de hack4u

# global variables
url="https://htbmachines.github.io/bundle.js"

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
    tput cnorm && exit 1
}

# help
function help(){
    echo -e "\n${GREEN}Uso:${NC} htbmachines.sh [opciones]\n"
    echo -e "${YELLOW} -m${NC} ${TURQUOISE}<nombre de la máquina>${NC}  Buscar máquina\n"
    echo -e "${YELLOW} -u${NC}  Actualizar máquinas\n"
    echo -e "${YELLOW} -h${NC}  Mostrar este mensaje\n"

    exit 1
}

# search machine
function search_machine(){
    machine_name=$1
    echo -e "\n${GREEN}Buscando máquina...${NC}\n"
    echo -e "${YELLOW}Máquina:${NC} $machine_name\n"
}

# update machines
function update_machines(){
    # hide cursor
    tput civis

    if [ ! -f bundle.js ]; then
        echo -e "\n${YELLOW}Descargando máquinas...${NC}\n"
        curl -s $url | js-beautify > bundle.js
        echo -e "${GREEN}Máquinas descargadas${NC}\n"
    else
        # check if there is any change
        checksum=$(curl -s $url | js-beautify | md5sum | awk '{print $1}')
        current_checksum=$(cat bundle.js | md5sum | awk '{print $1}')

        if [ $checksum != $current_checksum ]; then
            echo -e "\n${YELLOW}Actualizando máquinas...${NC}\n"
            curl -s $url | js-beautify > bundle.js
            echo -e "${GREEN}Máquinas actualizadas${NC}\n"
        else
            echo -e "\n${GREEN}No hay actualizaciones${NC}\n"
        fi
    fi
}

# menu
while getopts "hm:u" arg; do
    case $arg in
        m) search_machine $OPTARG;;
        u) update_machines;;
        h | *) help;;
    esac
done
