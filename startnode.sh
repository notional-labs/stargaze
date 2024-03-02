#!/bin/sh
set -eux
# create users
# rm -rf $HOME/.starsd
STARSD_BNIARY=starsd
$STARSD_BNIARY config chain-id stargaze-02
$STARSD_BNIARY config keyring-backend test
$STARSD_BNIARY config output json
yes | $STARSD_BNIARY keys add validator
yes | $STARSD_BNIARY keys add creator
yes | $STARSD_BNIARY keys add investor
yes | $STARSD_BNIARY keys add funder --pubkey "{\"@type\":\"/cosmos.crypto.secp256k1.PubKey\",\"key\":\"AtObiFVE4s+9+RX5SP8TN9r2mxpoaT4eGj9CJfK7VRzN\"}"
VALIDATOR=$($STARSD_BNIARY keys show validator -a)
CREATOR=$($STARSD_BNIARY keys show creator -a)
INVESTOR=$($STARSD_BNIARY keys show investor -a)
FUNDER=$($STARSD_BNIARY keys show funder -a)
RELAYER=stars19m0thsu0lumjw88mfjjepry43vmz7kh4cftpfs
DENOM=ustars
# setup chain
$STARSD_BNIARY init stargaze --chain-id stargaze-02
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

$STARSD_BNIARY genesis add-genesis-account $VALIDATOR 10000000000000000ustars
$STARSD_BNIARY genesis add-genesis-account $CREATOR 10000000000000000ustars
$STARSD_BNIARY genesis add-genesis-account $INVESTOR 10000000000000000ustars
$STARSD_BNIARY genesis add-genesis-account $FUNDER 10000000000000000ustars
$STARSD_BNIARY genesis add-genesis-account $RELAYER 10000000000000000ustars
\


$STARSD_BNIARY genesis gentx validator 10000000000ustars --chain-id stargaze-02 --keyring-backend test
$STARSD_BNIARY genesis collect-gentxs
$STARSD_BNIARY genesis validate-genesis
$STARSD_BNIARY start
