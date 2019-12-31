#!/bin/bash

CC_SRC_PATH="github.com/chaincode/marbles02_private/go"
LANGUAGE="golang"
CC_NAME="marbles_private"
VERSION="1.0"
CHANNEL_NAME="mychannel"

# import utils
. ./scripts/utils.sh

install_cc(){
  installChaincodeWithName 0 1 "$VERSION" "$CC_NAME"    
  installChaincodeWithName 0 2 "$VERSION" "$CC_NAME"    

  installChaincodeWithName 1 1 "$VERSION" "$CC_NAME"    
  installChaincodeWithName 1 2 "$VERSION" "$CC_NAME"    
}

instantiate_cc(){
  collections_path="/opt/gopath/src/$CC_SRC_PATH/../collections_config.json"
  instantiateChaincodeWithCollection 0 1 "$VERSION" "$CC_NAME" "$CHANNEL_NAME" "$collections_path"
  instantiateChaincodeWithCollection 0 2 "$VERSION" "$CC_NAME" "$CHANNEL_NAME" "$collections_path"

  # for instantiate running time.
  sleep 3
}

invoke_cc(){
  ARGS='{"Args":["initMarble"]}'
  MARBLE=$(echo -n "{\"name\":\"marble3\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\",\"price\":99}" | base64 | tr -d \\n)
  TRANSIENT_DATA="{\"marble\":\"$MARBLE\"}"
  chaincodeInvokeWithNameOfPDC 0 1 "$CC_NAME" "$CHANNEL_NAME" "$ARGS" "$TRANSIENT_DATA"
# for instantiate running time.
  sleep 3
}

query_cc(){
  ARGS='{"Args":["readMarblePrivateDetails","marble3"]}'
  res=$(chaincodeQueryWithName 0 1 "$CC_NAME" "$CHANNEL_NAME" "$ARGS")

  echo $res
}

#install_cc
#instantiate_cc
#invoke_cc
query_cc
