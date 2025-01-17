#!/bin/bash

CHAIN_DIR=./data

BINARY1=iris
CHAIN1_BOND_DENOM=uiris

BINARY2=uptickd
CHAIN2_BOND_DENOM=auptick

CHAINID_1=test-1
CHAINID_2=uptick_7000-1

VAL_MNEMONIC_1="clock post desk civil pottery foster expand merit dash seminar song memory figure uniform spice circle try happy obvious trash crime hybrid hood cushion"
VAL_MNEMONIC_2="angry twist harsh drastic left brass behave host shove marriage fall update business leg direct reward object ugly security warm tuna model broccoli choice"

DEMO_MNEMONIC_1="banner spread envelope side kite person disagree path silver will brother under couch edit food venture squirrel civil budget number acquire point work mass"
DEMO_MNEMONIC_2="veteran try aware erosion drink dance decade comic dawn museum release episode original list ability owner size tuition surface ceiling depth seminar capable only"

RLY_MNEMONIC_1="alley afraid soup fall idea toss can goose become valve initial strong forward bright dish figure check leopard decide warfare hub unusual join cart"
RLY_MNEMONIC_2="record gift you once hip style during joke field prize dust unique length more pencil transfer quit train device arrive energy sort steak upset"

P2PPORT_1=16656
P2PPORT_2=26656

RPCPORT_1=16657
RPCPORT_2=26657

RPCAPPPORT_1=16658
RPCAPPPORT_2=26658

RESTPORT_1=1316
RESTPORT_2=1317

ROSETTA_1=8080
ROSETTA_2=8081

#Stop iris if it is already running 
if pgrep -x "$BINARY1" >/dev/null; then
    echo "Terminating $BINARY1..."
    killall $BINARY1
fi

#Stop uptickd if it is already running 
if pgrep -x "$BINARY2" >/dev/null; then
    echo "Terminating $BINARY2..."
    killall $BINARY2
fi

echo "Removing previous data..."
rm -rf $CHAIN_DIR/$CHAINID_1 &> /dev/null
rm -rf $CHAIN_DIR/$CHAINID_2 &> /dev/null

# Add directories for both chains, exit if an error occurs
if ! mkdir -p $CHAIN_DIR/$CHAINID_1 2>/dev/null; then
    echo "Failed to create chain folder. Aborting..."
    exit 1
fi

if ! mkdir -p $CHAIN_DIR/$CHAINID_2 2>/dev/null; then
    echo "Failed to create chain folder. Aborting..."
    exit 1
fi

echo "Initializing $CHAINID_1..."
$BINARY1 init test --home $CHAIN_DIR/$CHAINID_1 --chain-id=$CHAINID_1

echo "Initializing $CHAINID_2..."
$BINARY2 init test --home $CHAIN_DIR/$CHAINID_2 --chain-id=$CHAINID_2

echo "Adding genesis accounts..."
echo $VAL_MNEMONIC_1 | $BINARY1 keys add val1 --home $CHAIN_DIR/$CHAINID_1 --recover --keyring-backend=test
echo $DEMO_MNEMONIC_1 | $BINARY1 keys add demowallet1 --home $CHAIN_DIR/$CHAINID_1 --recover --keyring-backend=test
echo $RLY_MNEMONIC_1 | $BINARY1 keys add rly1 --home $CHAIN_DIR/$CHAINID_1 --recover --keyring-backend=test 

echo $VAL_MNEMONIC_2 | $BINARY2 keys add val2 --home $CHAIN_DIR/$CHAINID_2 --recover --keyring-backend=test
echo $DEMO_MNEMONIC_2 | $BINARY2 keys add demowallet2 --home $CHAIN_DIR/$CHAINID_2 --recover --keyring-backend=test
echo $RLY_MNEMONIC_2 | $BINARY2 keys add rly2 --home $CHAIN_DIR/$CHAINID_2 --recover --keyring-backend=test 

$BINARY1 add-genesis-account $($BINARY1 --home $CHAIN_DIR/$CHAINID_1 keys show val1 --keyring-backend test -a) 100000000000$CHAIN1_BOND_DENOM  --home $CHAIN_DIR/$CHAINID_1
$BINARY1 add-genesis-account $($BINARY1 --home $CHAIN_DIR/$CHAINID_1 keys show demowallet1 --keyring-backend test -a) 100000000000$CHAIN1_BOND_DENOM  --home $CHAIN_DIR/$CHAINID_1
$BINARY1 add-genesis-account $($BINARY1 --home $CHAIN_DIR/$CHAINID_1 keys show rly1 --keyring-backend test -a) 100000000000$CHAIN1_BOND_DENOM  --home $CHAIN_DIR/$CHAINID_1

$BINARY2 add-genesis-account $($BINARY2 --home $CHAIN_DIR/$CHAINID_2 keys show val2 --keyring-backend test -a) 100000000000000000000000000$CHAIN2_BOND_DENOM  --home $CHAIN_DIR/$CHAINID_2
$BINARY2 add-genesis-account $($BINARY2 --home $CHAIN_DIR/$CHAINID_2 keys show demowallet2 --keyring-backend test -a) 100000000000000000000000000$CHAIN2_BOND_DENOM  --home $CHAIN_DIR/$CHAINID_2
$BINARY2 add-genesis-account $($BINARY2 --home $CHAIN_DIR/$CHAINID_2 keys show rly2 --keyring-backend test -a) 100000000000000000000000000$CHAIN2_BOND_DENOM  --home $CHAIN_DIR/$CHAINID_2

echo "Creating and collecting gentx..."
$BINARY1 gentx val1 7000000000$CHAIN1_BOND_DENOM --home $CHAIN_DIR/$CHAINID_1 --chain-id $CHAINID_1 --keyring-backend test
$BINARY1 collect-gentxs --home $CHAIN_DIR/$CHAINID_1

$BINARY2 gentx val2 70000000000000000000000000$CHAIN2_BOND_DENOM --home $CHAIN_DIR/$CHAINID_2 --chain-id $CHAINID_2 --keyring-backend test
$BINARY2 collect-gentxs --home $CHAIN_DIR/$CHAINID_2

echo "Changing defaults and ports in app.toml and config.toml files..."
sed -i -e 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:'"$P2PPORT_1"'"#g' $CHAIN_DIR/$CHAINID_1/config/config.toml
sed -i -e 's#"tcp://127.0.0.1:26657"#"tcp://127.0.0.1:'"$RPCPORT_1"'"#g' $CHAIN_DIR/$CHAINID_1/config/config.toml
sed -i -e 's#"tcp://127.0.0.1:26658"#"tcp://127.0.0.1:'"$RPCAPPPORT_1"'"#g' $CHAIN_DIR/$CHAINID_1/config/config.toml
sed -i -e 's/timeout-commit = "5s"/timeout_commit = "1s"/g' $CHAIN_DIR/$CHAINID_1/config/config.toml
sed -i -e 's/timeout-propose = "3s"/timeout_propose = "1s"/g' $CHAIN_DIR/$CHAINID_1/config/config.toml
sed -i -e 's/index_all_keys = false/index_all_keys = true/g' $CHAIN_DIR/$CHAINID_1/config/config.toml
sed -i -e 's/mode = "full"/mode = "validator"/g' $CHAIN_DIR/$CHAINID_1/config/config.toml
sed -i -e 's/enable = false/enable = true/g' $CHAIN_DIR/$CHAINID_1/config/app.toml
sed -i -e 's/swagger = false/swagger = true/g' $CHAIN_DIR/$CHAINID_1/config/app.toml
sed -i -e 's#"tcp://0.0.0.0:1317"#"tcp://0.0.0.0:'"$RESTPORT_1"'"#g' $CHAIN_DIR/$CHAINID_1/config/app.toml
#sed -i -e 's#":8080"#":'"$ROSETTA_1"'"#g' $CHAIN_DIR/$CHAINID_1/config/app.toml
sed -i -e "$(cat -n $CHAIN_DIR/$CHAINID_1/config/app.toml | grep '\[rosetta\]' -A3 | grep "enable =" | awk '{print $1}')s/enable = true/enable = false/" $CHAIN_DIR/$CHAINID_1/config/app.toml

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


sed -i -e 's/stake/uiris/g' $CHAIN_DIR/$CHAINID_1/config/genesis.json

sed -i -e 's/stake/auptick/g' $CHAIN_DIR/$CHAINID_2/config/genesis.json
sed -i -e 's/aphoton/auptick/g' $CHAIN_DIR/$CHAINID_2/config/genesis.json



# sed -i -e 's/stake/uiris/g' $CHAIN_DIR/$CHAINID_1/config/genesis.json