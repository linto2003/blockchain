#!/bin/bash

############################
# Setup anchor peer for hospital
# Set the context
# $1 = tls in case TLS need to be enabled

. bins/set-context.sh hospital $1

CHANNELS=$(peer channel list | sed -n '/Channels peers has joined:/,/^$/p' | tail -n +2)
if [ -n "$CHANNELS" ]; then
    echo "Channel already exists"
    peer channel fetch 0 ./medlinechannel.block -o $ORDERER_ADDRESS -c medlinechannel
else
    echo "No channels found"
    bins/createChannel.sh
fi
echo "Hospital Joining Channel"
# Give time for the channel tx to propagate
sleep 3s

# Join acme peer to the channel
bins/join-channel.sh

sleep 3s

# Update anchor peer in channel
bins/anchor-update.sh

############################
# Setup anchor peer for customer
# Set the context
# $1 = tls in case TLS need to be enabled
. bins/set-context.sh customer $1
echo "Customer Joining Channel"
# Join the budget peer
bins/join-channel.sh

sleep 3s

# Update anchor peer in channel
bins/anchor-update.sh

############################
# Setup anchor peer for pharmacy
# Set the context
# $1 = tls in case TLS need to be enabled
. bins/set-context.sh pharmacy $1
echo "Pharmacy Joining Channel"
# Join the pharmacy peer
bins/join-channel.sh

sleep 3s

# Update anchor peer in channel
bins/anchor-update.sh

. bins/set-context.sh delivery $1
echo "Delivery Joining Channel"
# Join the pharmacy peer
bins/join-channel.sh

sleep 3s

# Update anchor peer in channel
bins/anchor-update.sh