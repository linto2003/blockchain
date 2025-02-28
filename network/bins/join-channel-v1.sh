#!/bin/bash
#After running this script confirm that peer has joined
#by running peer channel list
#Check if the TLS is enabled
TLS_PARAMETERS=""
if [ "$CORE_PEER_TLS_ENABLED" == "true" ]; then
   echo "*** Executing with TLS Enabled ***"
   TLS_PARAMETERS=" --tls true --cafile $ORDERER_CA_ROOTFILE"
fi


if [ "$1" == "medlinechannel" ]; then
    echo "Joining medlinechannel"
    peer channel join   -b ./medlinechannel.block -o $ORDERER_ADDRESS $TLS_PARAMETERS
fi

if [ "$1" == "prescverchannel" ]; then
    echo "Joining prescverchannel"
    peer channel join   -b ./prescverchannel.block -o $ORDERER_ADDRESS $TLS_PARAMETERS
fi

if [ "$1" == "pharmafulchannel" ]; then
    echo "Joining pharmafulchannel"
    peer channel join   -b ./pharmafulchannel.block -o $ORDERER_ADDRESS $TLS_PARAMETERS
fi

if [ "$1" == "deliverychannel" ]; then
    echo "Joining deliverychannel"
    peer channel join   -b ./deliverychannel.block -o $ORDERER_ADDRESS $TLS_PARAMETERS
fi

