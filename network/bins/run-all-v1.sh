#!/bin/bash

############################
# Setup anchor peer for hospital
# Set the context
# $1 = tls in case TLS need to be enabled

if [ -z "$2" ]; then
    echo "Usage: run-all-v1.sh  tls channel_name"
    exit
fi

echo "Got --> $2"

function check_channel {
        bins/createChannel_v1.sh $1
}

function customer_join_channel {
    . bins/set-context-v1.sh customer $1 $2

    echo "Customer Joining Channel"
    # Give time for the channel tx to propagate
    sleep 3s

    # Join acme peer to the channel
    bins/join-channel-v1.sh $2

    sleep 3s

    # Update anchor peer in channel
    bins/anchor-update-v1.sh $2
}

function hospital_join_channel {
    . bins/set-context-v1.sh hospital $1 $2

    echo "Hospital Joining Channel"
    # Give time for the channel tx to propagate
    sleep 3s

    # Join acme peer to the channel
    bins/join-channel-v1.sh $2

    sleep 3s

    # Update anchor peer in channel
    bins/anchor-update-v1.sh $2
}

function delivery_join_channel {
    . bins/set-context-v1.sh delivery $1 $2

    echo "Delivery Joining Channel"
    # Give time for the channel tx to propagate
    sleep 3s

    # Join acme peer to the channel
    bins/join-channel-v1.sh $2

    sleep 3s

    # Update anchor peer in channel
    bins/anchor-update-v1.sh $2
}

function pharmacy_join_channel {
    . bins/set-context-v1.sh pharmacy $1 $2

    echo "Pharmacy Joining Channel"
    # Join the pharmacy peer
    bins/join-channel-v1.sh $2

    sleep 3s

    # Update anchor peer in channel
    bins/anchor-update-v1.sh $2
}

if [ "$2" == "medlinechannel" ]; then
    echo "Setting up medlinechannel"
    sleep 5s
    . bins/set-context-v1.sh customer $1 $2
    check_channel $2
    customer_join_channel $1 $2
    pharmacy_join_channel $1 $2
    delivery_join_channel $1 $2
fi

if [ "$2" == "prescverchannel" ]; then
    echo "Setting up presverchannel"
    sleep 5s
    . bins/set-context-v1.sh hospital $1 $2
    check_channel $2
    hospital_join_channel $1 $2
    pharmacy_join_channel $1 $2
    customer_join_channel $1 $2
fi

if [ "$2" == "pharmafulchannel" ]; then
    echo "Setting up pharmafulchannel"
    sleep 5s
    . bins/set-context-v1.sh pharmacy $1 $2
    check_channel $2
    pharmacy_join_channel $1 $2
    delivery_join_channel $1 $2
fi

if [ "$2" == "deliverychannel" ]; then
    echo "Setting up deliverychannel"
    sleep 5s
    . bins/set-context-v1.sh delivery $1 $2
    check_channel $2
    delivery_join_channel $1 $2
    customer_join_channel $1 $2
fi