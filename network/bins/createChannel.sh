#Check if the TLS is enabled
TLS_PARAMETERS=""
if [ "$CORE_PEER_TLS_ENABLED" == "true" ]; then
   echo "*** Executing with TLS Enabled ***"
   TLS_PARAMETERS=" --tls true --cafile $ORDERER_CA_ROOTFILE"
fi

peer channel create -c medlinechannel -f medlinechannel.tx --outputBlock medlinechannel.block -o $ORDERER_ADDRESS $TLS_PARAMETERS

# peer channel create -c medlinechannel -f medlinechannel.tx --outputBlock medlinechannel.block -o $ORDERER_ADDRESS --tls true --cafile $ORDERER_CA_ROOTFILE
# peer channel create -c medlinechannel -f medlinechannel.tx --outputBlock medlinechannel.block -o $ORDERER_ADDRESS 