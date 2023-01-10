#!/bin/bash

BINARY1=iris
BINARY2=uptickd

CHAIN_DIR=./data

CHAINID_1=test-1
GRPCPORT_1=8090
GRPCWEB_1=8091

CHAINID_2=uptick_7000-1
GRPCPORT_2=9090
GRPCWEB_2=9091

TRACE=""
LOGLEVEL="info"

echo "Starting $CHAINID_1 in $CHAIN_DIR..."
echo "Creating log file at $CHAIN_DIR/$CHAINID_1.log"

$BINARY1 start $TRACE --log_level $LOGLEVEL --minimum-gas-prices=0uiris \
--log_format json --home $CHAIN_DIR/$CHAINID_1 \
--pruning=nothing --grpc.address="0.0.0.0:$GRPCPORT_1" \
--grpc-web.address="0.0.0.0:$GRPCWEB_1" > $CHAIN_DIR/$CHAINID_1.log 2>&1 &

echo "Starting $CHAINID_2 in $CHAIN_DIR..."
echo "Creating log file at $CHAIN_DIR/$CHAINID_2.log"
# $BINARY 2start --log_format json --home $CHAIN_DIR/$CHAINID_2 --pruning=nothing --grpc.address="0.0.0.0:$GRPCPORT_2" --grpc-web.address="0.0.0.0:$GRPCWEB_2" > $CHAIN_DIR/$CHAINID_2.log 2>&1 &

$BINARY2 start $TRACE --log_level $LOGLEVEL --minimum-gas-prices=0auptick \
--json-rpc.api eth,txpool,personal,net,debug,web3 \
--log_format json --home $CHAIN_DIR/$CHAINID_2 \
--pruning=nothing --grpc.address="0.0.0.0:$GRPCPORT_2" \
--grpc-web.address="0.0.0.0:$GRPCWEB_2" > $CHAIN_DIR/$CHAINID_2.log 2>&1 &

# sleep 8

# # echo "TODO ..."
# uptickd tx bank send uptick1z3kehhtkjzdtd8kaz56srtp9e9wh9ywzwdy4w9 uptick100s3yp8l3atuuvx98jmftttxzy4ee5mg2n79fx \
# 1000000000auptick --chain-id uptick_7000-1 --home ./data/uptick_7000-1 \
# --node tcp://localhost:26657 --keyring-backend test -y



