#!/bin/bash

export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=false

# Generates Org3 certs using cryptogen tool
function generateCerts (){
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "###############################################################"
  echo "##### Generate Org3 certificates using cryptogen tool #########"
  echo "###############################################################"

  (cd org3-artifacts
   set -x
   cryptogen generate --config=./org3-crypto.yaml
   res=$?
   set +x
   if [ $res -ne 0 ]; then
     echo "Failed to generate certificates..."
     exit 1
   fi
  )
  echo
}

function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi
  echo "##########################################################"
  echo "#########  Generating Org3 config material ###############"
  echo "##########################################################"
  (cd org3-artifacts
   export FABRIC_CFG_PATH=$PWD
   set -x
   configtxgen -printOrg Org3MSP > ../channel-artifacts/org3.json
   res=$?
   set +x
   if [ $res -ne 0 ]; then
     echo "Failed to generate Org3 config material..."
     exit 1
   fi
  )
  cp -r crypto-config/ordererOrganizations org3-artifacts/crypto-config/
  echo
}

generateCerts
generateChannelArtifacts
set -x
ls ./channel-artifacts/org3.json
ls org3-artifacts/crypto-config/
