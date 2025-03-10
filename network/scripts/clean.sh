#!/bin/bash
#Usage:  ./clean.sh         Will clean the Orderer/Peer but will not remove artefacts
#Usage:  ./clean.sh all     In addition to above it will remove the network artefacts + crypto

sudo killall peer
sudo killall orderer
sudo killall fabric-ca-server

# Kill all running containers and then clean up
docker  kill $(docker ps -q)        &> /dev/null
docker  rm   $(docker ps -a -q)     &> /dev/null

if [ "$1" == "all" ]; then
    echo "Removing crypto & artefacts as well"
    sudo rm -rf ./crypto-config  &> /dev/null
    rm ./*.block  &> /dev/null
    rm ./*.tx  &> /dev/null
    rm ./orderer/*.block  &> /dev/null
fi

# echo "Removing ledger data for Orderer | Peers"
# docker volume rm acloudfan_data-peer1.acme.com
# docker volume rm acloudfan_data-peer1.budget.com
# docker volume rm acloudfan_data-orderer.acme.com
# docker network prune  -f

# Prune the network & volume
docker volume prune -f
docker network prune -f

echo    "Done [Ignore process not found messages]"