#!/bin/bash

cd ../uptick
make install

cd ../ics721-demo

killall uptickd


BINARY2=uptickd

CHAIN_DIR=./data
CHAINID_2=uptick_7000-1
GRPCPORT_2=9090
GRPCWEB_2=9091

TRACE=""
LOGLEVEL="info"


$BINARY2 start $TRACE --log_level $LOGLEVEL --minimum-gas-prices=0auptick \
--json-rpc.api eth,txpool,personal,net,debug,web3 \
--log_format json --home $CHAIN_DIR/$CHAINID_2 \
--pruning=nothing --grpc.address="0.0.0.0:$GRPCPORT_2" \
--grpc-web.address="0.0.0.0:$GRPCWEB_2" > $CHAIN_DIR/$CHAINID_2.log 2>&1 &
