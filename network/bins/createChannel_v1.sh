#!/bin/bash

# Check if the TLS is enabled
TLS_PARAMETERS=""
if [ "$CORE_PEER_TLS_ENABLED" == "true" ]; then
   echo "*** Executing with TLS Enabled ***"
   TLS_PARAMETERS=" --tls true --cafile $ORDERER_CA_ROOTFILE"
fi

if [ "$1" == "" ]; then
    echo "Usage:             createChannel_v1.sh  channel_name"
    echo "Usage with TLS  channel   createChannel_v1.sh channel_name"
    exit
fi

echo "Creating channel"
echo "Channel name: $1"

if [ "$1" == "medlinechannel" ]; then
    echo "Creating medlinechannel"
    peer channel create -c medlinechannel -f medlinechannel.tx --outputBlock medlinechannel.block -o $ORDERER_ADDRESS $TLS_PARAMETERS
fi

if [ "$1" == "prescverchannel" ]; then
    echo "Creating presverchannel"
    peer channel create -c prescverchannel -f prescverchannel.tx --outputBlock prescverchannel.block -o $ORDERER_ADDRESS $TLS_PARAMETERS
fi

if [ "$1" == "pharmafulchannel" ]; then
    echo "Creating pharmafulchannel"
    peer channel create -c pharmafulchannel -f pharmafulchannel.tx --outputBlock pharmafulchannel.block -o $ORDERER_ADDRESS $TLS_PARAMETERS
fi

if [ "$1" == "deliverychannel" ]; then
    echo "Creating deliverychannel"
    peer channel create -c deliverychannel -f deliverychannel.tx --outputBlock deliverychannel.block -o $ORDERER_ADDRESS $TLS_PARAMETERS
fi