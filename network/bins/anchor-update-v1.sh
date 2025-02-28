#!/bin/bash

# MUST provide 2 args 
# $1 = Path to configtx.yaml   $2 = asOrg  Acme \ Budget

#Check if the TLS is enabled
TLS_PARAMETERS=""
if [ "$CORE_PEER_TLS_ENABLED" == "true" ]; then
   echo "*** Executing with TLS Enabled ***"
   TLS_PARAMETERS=" --tls true --cafile $ORDERER_CA_ROOTFILE"
fi

PEER_FABRIC_CFG_PATH=$FABRIC_CFG_PATH

FABRIC_CFG_PATH=$PWD

if [ "$1" == "" ]; then
    echo "Usage:             anchor-update-v1.sh  channel_name"
    echo "Usage with TLS  channel   anchor-update-v1.sh channel_name"
    exit
fi

if [ "$1" == "medlinechannel" ]; then
    echo "Updating medlinechannel"

    configtxgen -outputAnchorPeersUpdate ./config/peer-update.tx   -asOrg $ORG_NAME -channelID medlinechannel  -profile MedlineChannel

    FABRIC_CFG_PATH=$PEER_FABRIC_CFG_PATH

    peer channel update -f ./config/peer-update.tx -c medlinechannel -o $ORDERER_ADDRESS $TLS_PARAMETERS

fi

if [ "$1" == "prescverchannel" ]; then
    echo "Updating presverchannel"

    configtxgen -outputAnchorPeersUpdate ./config/peer-update.tx   -asOrg $ORG_NAME -channelID prescverchannel  -profile PrescVerChannel

    FABRIC_CFG_PATH=$PEER_FABRIC_CFG_PATH

    peer channel update -f ./config/peer-update.tx -c prescverchannel -o $ORDERER_ADDRESS $TLS_PARAMETERS

fi

if [ "$1" == "pharmafulchannel" ]; then
    echo "Updating pharmafulchannel"

    configtxgen -outputAnchorPeersUpdate ./config/peer-update.tx   -asOrg $ORG_NAME -channelID pharmafulchannel  -profile PharmaFulChannel

    FABRIC_CFG_PATH=$PEER_FABRIC_CFG_PATH

    peer channel update -f ./config/peer-update.tx -c pharmafulchannel -o $ORDERER_ADDRESS $TLS_PARAMETERS

fi

if [ "$1" == "deliverychannel" ]; then
    echo "Updating deliverychannel"

    configtxgen -outputAnchorPeersUpdate ./config/peer-update.tx   -asOrg $ORG_NAME -channelID deliverychannel  -profile DeliveryChannel

    FABRIC_CFG_PATH=$PEER_FABRIC_CFG_PATH

    peer channel update -f ./config/peer-update.tx -c deliverychannel -o $ORDERER_ADDRESS $TLS_PARAMETERS

fi

# peer channel update -f ./config/peer-update.tx -c medlinechannel -o $ORDERER_ADDRESS --tls true --cafile $ORDERER_CA_ROOTFILE

