#!/bin/bash
#Launches the setup
if [ "$1" == "tls" ]; then

    echo "********************* Launching with TLS enabled *******************"
    docker-compose -f ./docker-compose-base.yaml -f ./docker-compose-tls.yaml -f ./docker-compose-couch.yaml up -d

elif [ "$1" == "raft" ]; then

    echo "********************* Launching with TLS RAFT *******************"
    docker-compose -f ./docker-compose-base.yaml -f ./docker-compose-tls.yaml -f ./docker-compose-raft.yaml up -d
    
else 
    #Default launch with TLS disabled
    docker-compose -f ./docker-compose-base.yaml up -d
fi