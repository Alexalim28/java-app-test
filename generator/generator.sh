#!/bin/bash

######################################
##                                  ##
##     Docker-Compose Generator     ##
##                                  ##
######################################

## Variables
DIR="${HOME}/generator"
USER=${USER}

## Fonctions
help() {
    echo ""
    echo "USAGE:
    ${0##*/} [-h] [--help]

    Options :
    -h, --help : Get help on this tool

    -p, --postgres : Launch a postgres instance

    -i, --ip : Display IPs
    "
}

ip(){
    for i in $(docker ps -aq); do docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} - {{.Name}}' $i; done; 
}

parse_args(){
    case $@ in
      -h|--help)
        help
      ;;

      -p|--postgres)
        postgres
      ;;

      *)
        echo "Invalid option, run --help or -h"
    esac
}

postgres(){
    echo ""
    echo "1 - Creation of the data directory"
    mkdir -p ${DIR}/postgres
    echo ""
    echo "2 - Creation of the docker-compose file"
    echo "
      version: '3.7'
      services:
        postgres_db:
          image: postgres
          container_name: postgres
          restart: always
          environment:
            - POSTGRES_PASSWORD=password
            - POSTGRES_USER=alexis
            - POSTGRES_DB=mydatabase
          networks:
            - generator
          ports:
            - 5432:5432
          volumes:
            - postgres_data:/var/lib/postgresql/data
      networks: 
        generator:
          ipam:
            driver: default
            config:
              - subnet: 192.168.0.0/24
      volumes:
        postgres_data:
          driver: local
          driver_opts:
            type: none
            o: bind
            device: ${DIR}/postgres
    " > ${DIR}/docker-compose-postgres.yml

    echo "3 - Running postgres instance"
    docker compose -f ${DIR}/docker-compose-postgres.yml up -d
    echo ""
    echo "
    Credentials :
      - PORT: 5432
      - POSTGRES_PASSWORD: password
      - POSTGRES_USER: alexis
      - POSTGRES_DB: mydatabase

    Command: psql -h <ip> -u alexis -d mydatabase
    "
}

## Execution

parse_args $@
ip
