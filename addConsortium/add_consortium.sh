export CORE_PEER_LOCALMSPID=OrdererMSP
export CORE_PEER_ADDRESS=orderer.example.com:7050
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

set -x 

echo "1. Get genesis.pb from orderer : create genesis.pb"
peer channel fetch config genesis.pb -o orderer.example.com:7050 -c byfn-sys-channel  --tls --cafile $ORDERER_CA

echo "Processing : (decode) change pb to json (genesis.pb => json type) "
configtxlator proto_decode --input genesis.pb --type common.Block | jq .data.data[0].payload.data.config > genesisBlock.json

echo "Processing : genesisBlockChanges.json create (consortium info add)"
jq -s '.[0] * {"channel_group":{"groups":{"Consortiums":{"groups":{"SampleConsortium":{"groups":{"Org3MSP":.[1]}}}}}}}' genesisBlock.json ./channel-artifacts/org3.json > genesisBlockChanges.json

echo "Processing: encode (create genesisBlock.pb)"
configtxlator proto_encode --input genesisBlock.json --type common.Config --output genesisBlock.pb

echo "Processing: encode (create genesisBlockChanges.pb)"
configtxlator proto_encode --input genesisBlockChanges.json --type common.Config --output genesisBlockChanges.pb

echo "Processing: compute updage (create genesisBlocProposal_Org3.pb)"
configtxlator compute_update --channel_id byfn-sys-channel --original genesisBlock.pb --updated genesisBlockChanges.pb --output genesisBlocProposal_Org3.pb

echo "Processing: decode (create genesisBlocProposal_Org3.json)"
configtxlator proto_decode --input genesisBlocProposal_Org3.pb --type common.ConfigUpdate | jq . > genesisBlocProposal_Org3.json

echo "Processing: create channel update payload (genesisBlocProposalReady.json)" 
echo '{"payload":{"header":{"channel_header":{"channel_id":"byfn-sys-channel", "type":2}},"data":{"config_update":'$(cat genesisBlocProposal_Org3.json)'}}}' | jq . > genesisBlocProposalReady.json

echo "Processing: encode (create genesisBlocProposalReady.pb)"
configtxlator proto_encode --input genesisBlocProposalReady.json --type common.Envelope --output genesisBlocProposalReady.pb

echo "channel update"
peer channel update -f genesisBlocProposalReady.pb -c byfn-sys-channel -o orderer.example.com:7050 --tls --cafile $ORDERER_CA

echo "add consortium complete"

peer channel fetch config genesis.pb2 -o orderer.example.com:7050 -c byfn-sys-channel  --tls --cafile $ORDERER_CA
configtxlator proto_decode --input genesis.pb2 --type common.Block | jq .data.data[0].payload.data.config > genesisBlock2.json

echo "org3 exist confirm"
jq .channel_group.groups.Consortiums.groups.SampleConsortium.groups.Org3MSP genesisBlock2.json | grep '"msp_identifier": "Org3MSP"' | wc -l
res=$?
if [ $res -eq 0 ]; then
	echo "SUCC"
else
	echo "FAIL"
fi
