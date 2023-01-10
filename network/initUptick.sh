#!/bin/bash

CHAIN_DIR=./data

BINARY2=uptickd
CHAIN2_BOND_DENOM=auptick
CHAINID_2=uptick_7000-1

VAL_MNEMONIC_2="angry twist harsh drastic left brass behave host shove marriage fall update business leg direct reward object ugly security warm tuna model broccoli choice"
DEMO_MNEMONIC_2="veteran try aware erosion drink dance decade comic dawn museum release episode original list ability owner size tuition surface ceiling depth seminar capable only"
RLY_MNEMONIC_2="record gift you once hip style during joke field prize dust unique length more pencil transfer quit train device arrive energy sort steak upset"

P2PPORT_2=26656
RPCPORT_2=26657
RPCAPPPORT_2=26658
RESTPORT_2=1317
ROSETTA_2=8081

#Stop uptickd if it is already running 
if pgrep -x "$BINARY2" >/dev/null; then
    echo "Terminating $BINARY2..."
    killall $BINARY2
fi

echo "Removing previous data..."
rm -rf $CHAIN_DIR/$CHAINID_2 &> /dev/null

if ! mkdir -p $CHAIN_DIR/$CHAINID_2 2>/dev/null; then
    echo "Failed to create chain folder. Aborting..."
    exit 1
fi

echo "Initializing $CHAINID_2..."
$BINARY2 init test --home $CHAIN_DIR/$CHAINID_2 --chain-id=$CHAINID_2

echo $VAL_MNEMONIC_2 | $BINARY2 keys add val2 --home $CHAIN_DIR/$CHAINID_2 --recover --keyring-backend=test
echo $DEMO_MNEMONIC_2 | $BINARY2 keys add demowallet2 --home $CHAIN_DIR/$CHAINID_2 --recover --keyring-backend=test
echo $RLY_MNEMONIC_2 | $BINARY2 keys add rly2 --home $CHAIN_DIR/$CHAINID_2 --recover --keyring-backend=test 

$BINARY2 add-genesis-account $($BINARY2 --home $CHAIN_DIR/$CHAINID_2 keys show val2 --keyring-backend test -a) 100000000000000000000000000$CHAIN2_BOND_DENOM  --home $CHAIN_DIR/$CHAINID_2
$BINARY2 add-genesis-account $($BINARY2 --home $CHAIN_DIR/$CHAINID_2 keys show demowallet2 --keyring-backend test -a) 100000000000000000000000000$CHAIN2_BOND_DENOM  --home $CHAIN_DIR/$CHAINID_2
$BINARY2 add-genesis-account $($BINARY2 --home $CHAIN_DIR/$CHAINID_2 keys show rly2 --keyring-backend test -a) 100000000000000000000000000$CHAIN2_BOND_DENOM  --home $CHAIN_DIR/$CHAINID_2

echo "Creating and collecting gentx..."
$BINARY2 gentx val2 70000000000000000000000000$CHAIN2_BOND_DENOM --home $CHAIN_DIR/$CHAINID_2 --chain-id $CHAINID_2 --keyring-backend test
$BINARY2 collect-gentxs --home $CHAIN_DIR/$CHAINID_2

sed -i -e 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:'"$P2PPORT_2"'"#g' $CHAIN_DIR/$CHAINID_2/config/config.toml
sed -i -e 's#"tcp://127.0.0.1:26657"#"tcp://127.0.0.1:'"$RPCPORT_2"'"#g' $CHAIN_DIR/$CHAINID_2/config/config.toml
sed -i -e 's#"tcp://127.0.0.1:26658"#"tcp://127.0.0.1:'"$RPCAPPPORT_2"'"#g' $CHAIN_DIR/$CHAINID_2/config/config.toml
sed -i -e 's/timeout-commit = "5s"/timeout_commit = "1s"/g' $CHAIN_DIR/$CHAINID_2/config/config.toml
sed -i -e 's/timeout_propose = "3s"/timeout_propose = "1s"/g' $CHAIN_DIR/$CHAINID_2/config/config.toml
sed -i -e 's/index_all_keys = false/index_all_keys = true/g' $CHAIN_DIR/$CHAINID_2/config/config.toml
sed -i -e 's/mode = "full"/mode = "validator"/g' $CHAIN_DIR/$CHAINID_2/config/config.toml
sed -i -e 's/enable = false/enable = true/g' $CHAIN_DIR/$CHAINID_2/config/app.toml
sed -i -e 's/swagger = false/swagger = true/g' $CHAIN_DIR/$CHAINID_2/config/app.toml
sed -i -e 's#"tcp://0.0.0.0:1317"#"tcp://0.0.0.0:'"$RESTPORT_2"'"#g' $CHAIN_DIR/$CHAINID_2/config/app.toml
#sed -i -e 's#":8080"#":'"$ROSETTA_2"'"#g' $CHAIN_DIR/$CHAINID_2/config/app.toml
sed -i -e "$(cat -n $CHAIN_DIR/$CHAINID_2/config/app.toml | grep '\[rosetta\]' -A3 | grep "enable =" | awk '{print $1}')s/enable = true/enable = false/" $CHAIN_DIR/$CHAINID_2/config/app.toml


sed -i -e 's/stake/auptick/g' $CHAIN_DIR/$CHAINID_2/config/genesis.json
sed -i -e 's/aphoton/auptick/g' $CHAIN_DIR/$CHAINID_2/config/genesis.json
