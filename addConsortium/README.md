#### 실행 정보

```
version
 - hyperledger : 1.4.1
file
 - pre-add_consortium.sh : org3 cert, channel artifacts 생성.
 - add_consortium.sh : orderer MSP 로 config block 에 org3 consortium 추가

pre-request
 - cp *.sh hyperledger/fabric-sample/first-network/
```



#### hyperledger/fabric-sample/first-network 으로 구축. (실행위치 : host)

```bash
cd fabric-sample/first-network
./byfn.sh up

# channel 생성 및 chaincode 수행은 생략가능
```



#### org3 cert, channel-artifacts 생성(실행위치 : host)

```Bash
cd first-network
# (eyfn.sh generate 수행 시 createConfigTx 만 제외한 것과 동일한 script)
./pre-add_consortium.sh  
...
+ ls ./channel-artifacts/org3.json
./channel-artifacts/org3.json
+ ls org3-artifacts/crypto-config/
ordererOrganizations peerOrganizations
```



#### org3 을 컨소시엄에 추가. (cli container)

```bash
# container cli 로 실행 script 복사
cd first-network
docker cp add_consortium.sh cli:/opt/gopath/src/github.com/hyperledger/fabric/peer

docker exec -it cli bash
#실행 후 org3MSP 의 consortium 포함 여부 확인 (있으면 SUCC, 없으면 FAIL)
./add_consortium.sh
...
=> org3 exist confirm
++ jq .channel_group.groups.Consortiums.groups.SampleConsortium.groups.Org3MSP genesisBlock2.json
++ wc -l
++ grep '"msp_identifier": "Org3MSP"'
SUCC
```















