configtxgen -outputCreateChannelTx  preschannel.tx -channelID preschannel  -profile PrescriptionVerificationChannel

peer channel create -c preschannel -f preschannel.tx --outputBlock preschannel.block -o $ORDERER_ADDRESS --tls true --cafile $ORDERER_CA_ROOTFILE

peer channel join   -b ./preschannel.block -o $ORDERER_ADDRESS --tls true --cafile $ORDERER_CA_ROOTFILE