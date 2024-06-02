#!/bin/bash
# Description: tutorial del curso de introducción a linux de hack4u

# global variables
url="https://htbmachines.github.io/bundle.js"
rx='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'

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

# ctrl + c function
function ctrl_c(){
    echo -e "\n${RED}Saliendo...${NC}\n"
    tput cnorm && exit 1
}

# help
function help(){
    echo -e "\n${GREEN}Uso:${NC} htbmachines.sh [opciones]\n"
    echo -e "${YELLOW} -m${NC} ${TURQUOISE}<nombre de la máquina>${NC}  Buscar máquina por nombre\n"
    echo -e "${YELLOW} -i${NC} ${TURQUOISE}<ip de la máquina>${NC}  Buscar máquina por ip\n"
    echo -e "${YELLOW} -d${NC} ${TURQUOISE}<dificultad>${NC}  Buscar máquinas por dificultad\n"
    echo -e "${YELLOW} -o${NC} ${TURQUOISE}<OS>${NC}  Buscar máquinas por OS\n"
    echo -e "${YELLOW} -l${NC} ${TURQUOISE}<nombre de la máquina>${NC}  Obtener link de youtube de la máquina\n"
    echo -e "${YELLOW} -u${NC}  Actualizar máquinas\n"
    echo -e "${YELLOW} -h${NC}  Mostrar este mensaje\n"

    exit 1
}

# search machine
function search_machine_name(){
    machine_name=$1

    # make the first letter uppercase
    machine_name=${machine_name^}

    echo -e "${TURQUOISE}Buscando la máquina${NF} ${YELLOW}${machine_name}${NC}\n"
    
    # check if the data is downloaded
    if [ ! -f bundle.js ]; then
        echo -e "\n${RED}No hay máquinas descargadas${NC}\n"
        echo -e "${YELLOW}Descargue las máquinas con:${NC} ${PURPLE}htbmachines.sh -u${NC}\n"
        exit 1
    fi
    
    # search machine by name
    info_maquina=$(cat bundle.js | awk "/name: \"${machine_name}\"/,/resuelta:/" | grep -vE "id|sku|resuelta" | tr -d "\"" | tr -d "," | sed 's/^ *//'  | sed 's/^ //')
    
    # check if the machine exists
    if [ -z "$info_maquina" ]; then
        echo -e "\n${RED}La máquina no existe${NC}\n"
        exit 1
    fi
    
    # print machine info
    echo -e "${WHITE}${info_maquina}${NC}\n"
}

# search machines by OS
function search_machines_os(){
    os=$1

    # check if the OS is valid
    if [[ $os == [Ww]indows ]]; then
        os="Windows"
    elif [[ $os == [Ll]inux ]]; then
        os="Linux"
    elif [[ $os == [Mm]ac ]]; then
        os="Mac"
    else
        echo -e "\n${RED}El OS no es válido${NC}\n"
        echo -e "${YELLOW}Los OS válidos son:${NC} ${PURPLE}Windows${NC}, ${PURPLE}Linux${NC} y ${PURPLE}Mac${NC}\n"
        exit 1
    fi

    # check if the data is downloaded
    if [ ! -f bundle.js ]; then
        echo -e "\n${RED}No hay máquinas descargadas${NC}\n"
        echo -e "${YELLOW}Descargue las máquinas con:${NC} ${PURPLE}htbmachines.sh -u${NC}\n"
        exit 1
    fi

    # search machines by OS
    machines_os=$(cat bundle.js | grep "so: \"${os}\"" -B 6 | grep "name: " | sed -E "s/\"|,//g" | awk '{print $NF}')

    # check if there are machines with the specified OS
    if [ -z "$machines_os" ]; then
        echo -e "\n${RED}No hay máquinas con OS ${NC}${PURPLE}${os}${NC}\n"
        exit 1
    fi
    
    # print machines with the specified OS
    echo -e "${GRAY}Máquinas con OS ${NC}${PURPLE}${os}${NC}${GRAY}:${NC}\n"
    
    # print machines
    for machine in $machines_os; do
        echo -e "${WHITE}${machine}${NC}"
    done
}

# get yt link by machine name
function get_yt_link(){
    machine_name=$1

    # make the first letter uppercase
    machine_name=${machine_name^}

    # check if the data is downloaded
    if [ ! -f bundle.js ]; then
        echo -e "\n${RED}No hay máquinas descargadas${NC}\n"
        echo -e "${YELLOW}Descargue las máquinas con:${NC} ${PURPLE}htbmachines.sh -u${NC}\n"
        exit 1
    fi

    # get yt link by machine name
    yt_link=$(cat bundle.js | awk "/name: \"${machine_name}\"/,/youtube:/" | grep "youtube: " | awk '{print $NF}' | sed -E 's/\"|,//g')

    # check if the machine exists
    if [ -z "$yt_link" ]; then
        echo -e "\n${RED}La máquina no existe${NC}\n"
        exit 1
    fi

    # print yt link
    echo -e "${GRAY}El link de youtube de la máquina ${NC}${YELLOW}${machine_name}${NC}${GRAY} es ${NC}${BLUE}${yt_link}${NC}\n"
}

# update machines
function update_machines(){
    # hide cursor
    tput civis
    
    # check if the data is downloaded
    if [ ! -f bundle.js ]; then
        echo -e "\n${YELLOW}Descargando máquinas...${NC}\n"
        curl -s $url | js-beautify > bundle.js
        echo -e "${GREEN}Máquinas descargadas${NC}\n"
    else
        # check if there is any change
        checksum=$(curl -s $url | js-beautify | md5sum | awk '{print $1}')
        current_checksum=$(cat bundle.js | md5sum | awk '{print $1}')
        
        # check if there is any change
        if [ $checksum != $current_checksum ]; then
            echo -e "\n${YELLOW}Actualizando máquinas...${NC}\n"
            curl -s $url | js-beautify > bundle.js
            echo -e "${GREEN}Máquinas actualizadas${NC}\n"
        else
            echo -e "\n${GREEN}No hay actualizaciones${NC}\n"
        fi
    fi
}

# search machine by ip
function search_machine_ip() {
    ip=$1

    # chek if the ip is valid
    if [[ ! $ip =~ ^$rx\.$rx\.$rx\.$rx$ ]]; then
        echo -e "\n${RED}La ip no es válida${NC}\n"
        exit 1
    fi

    # check if the data is downloaded
    if [ ! -f bundle.js ]; then
        echo -e "\n${RED}No hay máquinas descargadas${NC}\n"
        echo -e "${YELLOW}Descargue las máquinas con:${NC} ${PURPLE}htbmachines.sh -u${NC}\n"
        exit 1
    fi

    machine_name=$(cat bundle.js | grep "ip: \"${ip}\"" -B 3 | grep "name: " | sed -E 's/\"|,//g' | awk '{print $NF}')

    if [ -z "$machine_name" ]; then
        echo -e "\n${RED}La máquina no existe${NC}\n"
        exit 1
    fi

    echo -e "${GRAY}La máquina con ip ${NC}${BLUE}${ip}${NC}${GRAY} es ${NC}${PURPLE}${machine_name}${NC}\n"

    search_machine_name $machine_name
}

# search machines by dificulty
function search_machines_dificulty() {
    dificultad=$1

    # check if the dificulty is valid
    if [[ $dificultad == [Ff][áa]cil ]]; then
        dificultad="Fácil"
    elif [[ $dificultad == [Mm]edia ]]; then
        dificultad="Media"
    elif [[ $dificultad == [Dd]if[íi]cil ]]; then
        dificultad="Difícil"
    elif [[ $dificultad == [Ii]nsane ]]; then
        dificultad="Insane"
    else
        echo -e "\n${RED}La dificultad no es válida${NC}\n"
        echo -e "${YELLOW}Las dificultades válidas son:${NC} ${PURPLE}Fácil${NC}, ${PURPLE}Media${NC}, ${PURPLE}Difícil${NC} e ${PURPLE}Insane${NC}\n"
        exit 1
    fi

    # check if the data is downloaded
    if [ ! -f bundle.js ]; then
        echo -e "\n${RED}No hay máquinas descargadas${NC}\n"
        echo -e "${YELLOW}Descargue las máquinas con:${NC} ${PURPLE}htbmachines.sh -u${NC}\n"
        exit 1
    fi
    
    # search machines by dificulty
    machines_dificulty=$(cat bundle.js | grep "dificultad: \"${dificultad}\"" -B 5 | grep "name: " | sed -E "s/\"|,//g" | awk '{print $NF}')

    # check if there are machines with the specified dificulty
    if [ -z "$machines_dificulty" ]; then
        echo -e "\n${RED}No hay máquinas con dificultad ${NC}${PURPLE}${dificultad}${NC}\n"
        exit 1
    fi
    
    # print machines with the specified dificulty
    echo -e "${GRAY}Máquinas con dificultad ${NC}${PURPLE}${dificultad}${NC}${GRAY}:${NC}\n"
    
    # print machines
    for machine in $machines_dificulty; do
        echo -e "${WHITE}${machine}${NC}"
    done

}

# search machine by OS and dificulty
function search_machine_os_difficulty(){
    os=$1
    difficulty=$2

    # check if the OS is valid
    if [[ $os == [Ww]indows ]]; then
        os="Windows"
    elif [[ $os == [Ll]inux ]]; then
        os="Linux"
    elif [[ $os == [Mm]ac ]]; then
        os="Mac"
    else
        echo -e "\n${RED}El OS no es válido${NC}\n"
        echo -e "${YELLOW}Los OS válidos son:${NC} ${PURPLE}Windows${NC}, ${PURPLE}Linux${NC} y ${PURPLE}Mac${NC}\n"
        exit 1
    fi

    # check if the dificulty is valid
    if [[ $difficulty == [Ff][áa]cil ]]; then
        difficulty="Fácil"
    elif [[ $difficulty == [Mm]edia ]]; then
        difficulty="Media"
    elif [[ $difficulty == [Dd]if[íi]cil ]]; then
        difficulty="Difícil"
    elif [[ $difficulty == [Ii]nsane ]]; then
        difficulty="Insane"
    else
        echo -e "\n${RED}La dificultad no es válida${NC}\n"
        echo -e "${YELLOW}Las dificultades válidas son:${NC} ${PURPLE}Fácil${NC}, ${PURPLE}Media${NC}, ${PURPLE}Difícil${NC} e ${PURPLE}Insane${NC}\n"
        exit 1
    fi

    # check if the data is downloaded
    if [ ! -f bundle.js ]; then
        echo -e "\n${RED}No hay máquinas descargadas${NC}\n"
        echo -e "${YELLOW}Descargue las máquinas con:${NC} ${PURPLE}htbmachines.sh -u${NC}\n"
        exit 1
    fi

    # search machines by OS and dificulty
    machines_os_difficulty=$(cat bundle.js | grep "so: \"${os}\"" -B 6 | grep "dificultad: \"${difficulty}\"" -B 5 | grep "name: " | sed -E "s/\"|,//g" | awk '{print $NF}')

    # check if there are machines with the specified OS and dificulty
    if [ -z "$machines_os_difficulty" ]; then
        echo -e "\n${RED}No hay máquinas con OS ${NC}${PURPLE}${os}${NC}${RED} y dificultad ${NC}${PURPLE}${difficulty}${NC}\n"
        exit 1
    fi

    # print machines with the specified OS and dificulty
    echo -e "${GRAY}Máquinas con OS ${NC}${PURPLE}${os}${NC}${GRAY} y dificultad ${NC}${PURPLE}${difficulty}${NC}${GRAY}:${NC}\n"
}

search_machine_os_flag=false
search_machines_dificulty_flag=false

# menu
while getopts "hm:ui:d:l:o:" arg; do
    case $arg in
        m) search_machine_name $OPTARG;;
        u) update_machines;;
        o) search_machine_os_flag=true;machine_os=$OPTARG;;
        i) search_machine_ip $OPTARG;;
        d) search_machines_dificulty_flag=true;machine_difficulty=$OPTARG;;
        l) get_yt_link $OPTARG;;
        h | *) help;;
    esac
done

# search machines by OS and dificulty
if [ $search_machine_os_flag = true ] && [ $search_machines_dificulty_flag = true ]; then
    search_machine_os_difficulty $machine_os $machine_difficulty
elif [ $search_machine_os_flag = true ]; then
    search_machines_os $machine_os
elif [ $search_machines_dificulty_flag = true ]; then
    search_machines_dificulty $machine_difficulty
fi
