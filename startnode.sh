#!/bin/sh
set -eux
# create users
# rm -rf $HOME/.starsd
STARSD_BINARY=starsd
$STARSD_BINARY config chain-id stargaze-02
$STARSD_BINARY config keyring-backend test
$STARSD_BINARY config output json
yes | $STARSD_BINARY keys add validator
yes | $STARSD_BINARY keys add creator
yes | $STARSD_BINARY keys add investor
yes | $STARSD_BINARY keys add funder --pubkey "{\"@type\":\"/cosmos.crypto.secp256k1.PubKey\",\"key\":\"AtObiFVE4s+9+RX5SP8TN9r2mxpoaT4eGj9CJfK7VRzN\"}"
VALIDATOR=$($STARSD_BINARY keys show validator -a)
CREATOR=$($STARSD_BINARY keys show creator -a)
INVESTOR=$($STARSD_BINARY keys show investor -a)
FUNDER=$($STARSD_BINARY keys show funder -a)
RELAYER=stars19m0thsu0lumjw88mfjjepry43vmz7kh4cftpfs
DENOM=ustars
# setup chain
$STARSD_BINARY init stargaze --chain-id stargaze-02
gsed -i "s/\"stake\"/\"$DENOM\"/g" ~/.starsd/config/genesis.json
# modify config for development
config="$HOME/.starsd/config/config.toml"
if [ "$(uname)" = "Linux" ]; then
  gsed -i "s/cors_allowed_origins = \[\]/cors_allowed_origins = [\"*\"]/g" $config
else
  gsed -i "s/cors_allowed_origins = \[\]/cors_allowed_origins = [\"*\"]/g" $config
fi
gsed -i "s/\"stake\"/\"$DENOM\"/g" ~/.starsd/config/genesis.json
# modify genesis params for localnet ease of use
# x/gov params change
# reduce voting period to 2 minutes
contents="$(jq '.app_state.gov.params.voting_period = "120s"' $HOME/.starsd/config/genesis.json)" && echo "${contents}" >  $HOME/.starsd/config/genesis.json
# reduce minimum deposit amount to 10stake
contents="$(jq '.app_state.gov.params.min_deposit[0].amount = "10"' $HOME/.starsd/config/genesis.json)" && echo "${contents}" >  $HOME/.starsd/config/genesis.json
# reduce deposit period to 20seconds 
contents="$(jq '.app_state.gov.params.max_deposit_period = "20s"' $HOME/.starsd/config/genesis.json)" && echo "${contents}" >  $HOME/.starsd/config/genesis.json

$STARSD_BINARY genesis add-genesis-account $VALIDATOR 10000000000000000ustars
$STARSD_BINARY genesis add-genesis-account $CREATOR 10000000000000000ustars
$STARSD_BINARY genesis add-genesis-account $INVESTOR 10000000000000000ustars
$STARSD_BINARY genesis add-genesis-account $FUNDER 10000000000000000ustars
$STARSD_BINARY genesis add-genesis-account $RELAYER 10000000000000000ustars
\


$STARSD_BINARY genesis gentx validator 10000000000ustars --chain-id stargaze-02 --keyring-backend test
$STARSD_BINARY genesis collect-gentxs
$STARSD_BINARY genesis validate-genesis
$STARSD_BINARY start
