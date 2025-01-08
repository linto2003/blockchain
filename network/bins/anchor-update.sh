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

configtxgen -outputAnchorPeersUpdate ./config/peer-update.tx   -asOrg $ORG_NAME -channelID medlinechannel  -profile MedlineChannel

FABRIC_CFG_PATH=$PEER_FABRIC_CFG_PATH

peer channel update -f ./config/peer-update.tx -c medlinechannel -o $ORDERER_ADDRESS $TLS_PARAMETERS
# peer channel update -f ./config/peer-update.tx -c medlinechannel -o $ORDERER_ADDRESS --tls true --cafile $ORDERER_CA_ROOTFILE