#!/bin/bash
#Sets the context for native peer commands

function usage {
    echo "Usage:             . ./set-context.sh  ORG_NAME"
    echo "Usage with TLS  channel   . ./set-context.sh  ORG_NAME  tls channel_name"
    echo "           Sets the organization context for native peer execution"
}

if [ "$1" == "" ]; then
    usage
    exit
fi

if [ "$2" == "" ]; then
    usage
    exit
fi

if [ "$3" == "" ]; then
    usage
    exit
fi

export ORG_CONTEXT=$1
MSP_ID="$(tr '[:lower:]' '[:upper:]' <<< ${ORG_CONTEXT:0:1})${ORG_CONTEXT:1}"
export ORG_NAME=$MSP_ID

# Added this Oct 22
export CORE_PEER_LOCALMSPID=$ORG_NAME"MSP"

# Logging specifications
export FABRIC_LOGGING_SPEC=INFO

# Location of the core.yaml
export FABRIC_CFG_PATH=$PWD/$1

# Address of the peer
export CORE_PEER_ADDRESS=peer1.$1.com:7051

if [ "$ORG_CONTEXT" == "customer" ]; then
    # Native binary uses the local port on VM 
    export CORE_PEER_ADDRESS=peer1.$1.com:8051
fi
if [ "$ORG_CONTEXT" == "pharmacy" ]; then
    # Native binary uses the local port on VM 
    export CORE_PEER_ADDRESS=peer1.$1.com:9051
fi
if [ "$ORG_CONTEXT" == "delivery" ]; then
    # Native binary uses the local port on VM 
    export CORE_PEER_ADDRESS=peer1.$1.com:10051
fi


# Local MSP for the admin - Commands need to be executed as org admin
export CORE_PEER_MSPCONFIGPATH=$PWD/crypto-config/peerOrganizations/$1.com/users/Admin@$1.com/msp

# Address of the orderer
export ORDERER_ADDRESS=orderer.hospital.com:7050

# RAFT requires TLS
if [ "$2" == "tls" ] || [ "$2" == "raft" ] ; then

    export ORDERER_CA_ROOTFILE=$PWD/crypto-config/ordererOrganizations/hospital.com/orderers/orderer.hospital.com/msp/tlscacerts/tlsca.hospital.com-cert.pem
    export CORE_PEER_TLS_CERT_FILE=$PWD/crypto-config/peerOrganizations/$1.com/peers/peer1.$1.com/tls/server.crt
    export CORE_PEER_TLS_KEY_FILE=$PWD/crypto-config/peerOrganizations/$1.com/peers/peer1.$1.com/tls/server.key
    export CORE_PEER_TLS_ROOTCERT_FILE=$PWD/crypto-config/peerOrganizations/$1.com/peers/peer1.$1.com/tls/ca.crt

    export CORE_PEER_TLS_ENABLED=true
    
else
    export CORE_PEER_TLS_ENABLED=false
fi



### Introduced in Fabric 2.x update
### Test Chaincode related properties

export CC_CHANNEL_ID=$3


export CC_CONSTRUCTOR='{"Args":["InitLedger"]}'
if [ "$3" == "medlinechannel" ]; then
    export CC_NAME="go_ordcc_1"
    export CC_PATH="github.com/linto/Project/Project_new/network/cc_order"
fi

if [ "$3" == "presverchannel" ]; then
    export CC_NAME="go_ver_1"
    export CC_PATH="github.com/linto/Project/Project_new/network/cc_ver"
fi

if [ "$3" == "pharmafulchannel" ]; then
    export CC_NAME="go_ff_1"
    export CC_PATH="github.com/linto/Project/Project_new/network/cc_fulfil"
fi

if [ "$3" == "deliverychannel" ]; then
    export CC_NAME="go_del_1"
    export CC_PATH="github.com/linto/Project/Project_new/network/cc_del"
fi

export CC_VERSION="1.0"
export CC_LANGUAGE="golang"

# Version 2.x
export INTERNAL_DEV_VERSION="1.0"
export CC2_PACKAGE_FOLDER="$HOME/packages"
export CC2_SEQUENCE=1
export CC2_INIT_REQUIRED="--init-required"

# Create the package with this name
export PACKAGE_NAME="$CC_NAME.$CC_VERSION-$INTERNAL_DEV_VERSION.tar.gz"
# Extracts the package ID for the installed chaincode
export LABEL="$CC_NAME.$CC_VERSION-$INTERNAL_DEV_VERSION"

#CHANNEL_CREATE_COMMAND
#peer channel create -c medlinechannel -f medlinechannel.tx --outputBlock medlinechannel.block -o $ORDERER_ADDRESS

#peer channel update -f ./peer-update.tx -c medlinechannel -o $ORDERER_ADDRESS 

# IF 2 chaincodes are there then:

# # Package chaincode1
# peer lifecycle chaincode package ./packages/chaincode1.tar.gz -p ./chaincode/chaincode1 --label="chaincode1_1.0"

# # Package chaincode2
# peer lifecycle chaincode package ./packages/chaincode2.tar.gz -p ./chaincode/chaincode2 --label="chaincode2_1.0"
# # Install chaincode1
# peer lifecycle chaincode install ./packages/chaincode1.tar.gz

# # Install chaincode2
# peer lifecycle chaincode install ./packages/chaincode2.tar.gz

# # Approve chaincode1
# peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --channelID mychannel --name chaincode1 --version 1.0 --package-id <PACKAGE_ID_CHAINCODE1> --sequence 1

# # Approve chaincode2
# peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --channelID mychannel --name chaincode2 --version 1.0 --package-id <PACKAGE_ID_CHAINCODE2> --sequence 1

# # Commit chaincode1
# peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --name chaincode1 --version 1.0 --sequence 1

# # Commit chaincode2
# peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --name chaincode2 --version 1.0 --sequence 1