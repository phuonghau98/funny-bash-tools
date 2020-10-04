#!/bin/bash

SOURCE_HOST='127.0.0.1'
SOURCE_PORT='27017'
TARGET_HOST='127.0.0.1'
SOURCE_TARGET='27017'
RUNNING_INSTANCE_PLATFORM='native'
SELECTED_SOURCE_CONTAINER=''

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
    IFS=';' read -r -a options <<< "$2"
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
            eval "$1='${options[$selected_i]}'"
            break
        fi
    done
}

select_docker_container () {
    local selected_container=''
    local __variable_name=$1
    containers=$(docker ps | grep mongo | awk '{ printf("%15s\t%s\n",$NF,$(NF-1)) }' | tr '\n' ';')
    prompt_choice selected_container "$containers"

    # Return value
    eval $__variable_name="'$selected_container'"
}

get_mongodb_container_port () {
    docker port $1 | grep -oP '(?<=-> 0.0.0.0:)\d+'
}

select_database_docker_container () {
    local selected_container=$2
    local __variable_name=$1
    local databases=()
    local selected_database=''
    IFS=' ' read -r -a databases < <(docker exec \
    -it $selected_container mongo --eval "db.adminCommand('listDatabases')" | \
    grep -oP "(?<=\"name\" : \")\w+" | grep -vP 'local|admin|config')
    prompt_choice selected_database "$(printf '%s;' ${databases[@]})"
    echo "Selected: $selected_database"
    # Return value
    eval $__variable_name="'$selected_database'"
}

is_docker_database_exist () {
    local container=$1
    local db=$2
    index=$(docker exec -it $container mongo --eval  'db.getMongo().getDBNames().indexOf("'$db'")' --quiet)
    # RETURN VALUE
    echo $index | grep -oP -- "-?[0-9]+"
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

# check_dependencies

print_section "SELECT SOURCE PLATFORM"

echo "Which platform does source Mongo instance is running on?"
prompt_choice RUNNING_INSTANCE_PLATFORM "docker;native"

case $RUNNING_INSTANCE_PLATFORM in
    docker)
        containers_arr=()
        databases=()
        SELECTED_SOURCE_DATABASE=''
        SELECTED_SRC_CONTAINER=''
        SELECTED_DST_CONTAINER=''
        SELECTED_DST_DB=''
        SELECTED_SRC_DB=''
        DUMP_ARCHIVE=''
        print_section "SELECT SOURCE CONTAINER"
        echo "Which container is your MongoDB source?"
        select_docker_container SELECTED_SRC_CONTAINER
        SELECTED_SRC_CONTAINER=$(echo $SELECTED_SRC_CONTAINER | awk '{ print $1 }')
        print_section "SELECT SOURCE DATABASE"
        select_database_docker_container SELECTED_SRC_DB $SELECTED_SRC_CONTAINER
        [ "${#SELECTED_SRC_DB}" -lt 1 ] && exit 1
        container_port=$(get_mongodb_container_port $SELECTED_SRC_CONTAINER)
        # mongodump --port=$container_port --db=$SELECTED_SRC_DB --archive=$DUMP_ARCHIVE

        print_section "SELECT TARGET PLATFORM"

        echo "Which platform does target MongoDB instance is running on?"
        prompt_choice TARGET_RUNNING_INSTANCE_PLATFORM "docker;native"

        case $TARGET_RUNNING_INSTANCE_PLATFORM in
            docker)
                print_section "SELECT SOURCE CONTAINER"
                select_docker_container SELECTED_DST_CONTAINER
                SELECTED_DST_CONTAINER=$(echo $SELECTED_DST_CONTAINER | awk '{printf $1}')
                while true
                do
                    read -p "Enter name of the output database: " SELECTED_DST_DB

                    if [[ "${#SELECTED_DST_DB}" -gt 0 ]]
                    then
                        found="$(is_docker_database_exist $SELECTED_DST_CONTAINER $SELECTED_DST_DB)"
                        if [[ "$found" -ne -1 ]]
                        then
                            echo "Database name exist on this container, please pick other name"
                        else
                            break
                        fi
                    fi
                done

                echo -n "Please confirm the executing command: mongodump --archive --db=$SELECTED_SRC_DB --port=$(get_mongodb_container_port $SELECTED_SRC_CONTAINER) | mongorestore --archive --port=$(get_mongodb_container_port $SELECTED_DST_CONTAINER) --nsFrom="$SELECTED_SRC_DB.*" --nsTo="$SELECTED_DST_DB.*""
                echo -e "\n"
                read -p "Is this correct?(Y/n): " confirm
                case $confirm in
                    Y)
                        mongodump --archive --db=$SELECTED_SRC_DB --port=$(get_mongodb_container_port $SELECTED_SRC_CONTAINER) | mongorestore --archive --port=$(get_mongodb_container_port $SELECTED_DST_CONTAINER) --nsFrom="$SELECTED_SRC_DB.*" --nsTo="$SELECTED_DST_DB.*"
                        ;;
                    *)
                        echo "Aborted"
                        exit 0
                        ;;
                esac
                ;;
            *)
                echo "Unimplemented"
                exit 1
                ;;
        esac

        # IFS=$'\n' read -r -a containers_arr < <(docker ps | grep 27017 | awk '{print $1" "$2}')
        # SELECTED_SOURCE_CONTAINER=$(echo $SELECTED_SOURCE_CONTAINER | awk '{printf $1}')
        # print_section "SELECT SOURCE DATABASE"
        # ch="${databases[@]}"
        # prompt_choice SELECTED_SOURCE_DATABASE "$ch"
        ;;
    *)
        echo "Unimplemented platform"
        ;;
esac
