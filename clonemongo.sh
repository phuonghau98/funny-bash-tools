#!/bin/bash

SOURCE_HOST='127.0.0.1'
SOURCE_PORT='27017'
TARGET_HOST='127.0.0.1'
SOURCE_TARGET='27017'
RUNNING_INSTANCE_PLATFORM='native'

commands_exists () {
    type "$@" > /dev/null 2>&1
}

prompt_choice () {
    # Print options
    local options=()

    # Reconstruct array of options from parameters
    for opt in $2
    do
        options+=("$opt")
    done
    # echo $options
    # Print options
    for i in "${!options[@]}"
    do
        echo "[$(($i + 1))]" "${options[$i]}"
        i=$(($i + 1))
    done
    ask () {
        echo -n "Your choice [default: 1]: "
        read choice
    }
    re='^$|^[0-9]$'

    ask

    while true
    do
        if ! [[ "$choice" =~ $re ]]; then
            echo "You must enter a number or leave it as default"
            ask
        elif [[ $choice -gt "${#options[@]}" ]]; then
            echo "Invalid choice"
            ask
        else
            selected_i=$(($choice - 1))
            eval "$1=${options[$selected_i]}"
            break
        fi
    done
}

print_section () {
    echo "================== $1 =================="
}


check_dependencies () {
    print_section "CHECKING DEPENDENCIES"
    if ! commands_exists mongodump; then
        echo "Mongo tools did not exist, installing..."
        wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
        if [ $? -eq 0 ]; then echo "GPG key added"; else exit 1; fi
        os_release_code=$(lsb_release -cs)
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $os_release_code/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
        sudo apt-get update > /dev/null
        if [ $? -ne 0 ]; then
            echo "Cannot run apt-get update" && exit 1;
        fi
        sudo apt-get install -y mongodb-org-tools > /dev/null
        if [ $? -ne 0 ]; then
            echo "Cannot install mongodb-org-tools" && exit 1;
        else 
            echo "mongodb-org-tools: Installed"
        fi
    else
        echo "Dependencies: OK"
    fi
}

check_dependencies

print_section "SELECT SOURCE PLATFORM"

echo "Which platform does source Mongo instance is running on?"
prompt_choice RUNNING_INSTANCE_PLATFORM "docker native"

case $RUNNING_INSTANCE_PLATFORM in
    docker)
        containers=()
        databases=()
        print_section "SELECT SOURCE CONTAINER"
        echo "Which container is your MongoDB source?"
        IFS=$'\n' read -d '' -r -a containers < <(docker ps | grep 27017 | awk '{print $1"_"$2}')
        SELECTED_CONTAINER=''
        prompt_choice SELECTED_CONTAINER $containers
        echo $SELECTED_CONTAINER
        # docker exec -it 44fd8ebc85ef mongo --eval "db.adminCommand('listDatabases')" | grep -oP "(?<=\"name\" : \")\w+"
        print_section "SELECT SOURCE DATABASE"
        IFS=' ' read -r -a databases < <(docker exec -it 44fd8ebc85ef mongo --eval "db.adminCommand('listDatabases')" | grep -oP "(?<=\"name\" : \")\w+" | tr '\n' ' ')
        ch="${databases[@]}"
        prompt_choice SELECTED_DATABASE "$ch"
        ;;
    *)
        echo "Unimplemented platform"
        ;;
esac
