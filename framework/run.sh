#!/bin/bash

if [ ${BASH_SOURCE[0]} ]; then
    EXE_DIR=`dirname "${BASH_SOURCE[0]}"`
else
    EXE_DIR=$PWD/`dirname "${BASH_SOURCE[0]}"`
fi

cd $EXE_DIR
current_path=$PWD


reset_network(){
  cd $EXE_DIR/.env 
  ./byfn.sh down && docker rm $(docker ps -qa) && docker network rm net_byfn
 echo "check remain(alive) container"
 read
 ./byfn.sh up -a -s couchdb
}

#channel_create(){
#    source conf # read channel name

#}
run_test(){
  cd $current_path
  target=${1:-marbles02_private}
  #source ./conf # TODO : read chaincode
  testcase_dir=testcase/$target  

  docker cp $testcase_dir/test.sh cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/
  set +x 
  docker exec cli bash -c './test.sh'
#  res=$(docker exec cli cat result.log | grep "SUCC | wc -l")
#  docker exec cli bash -c "rm -f result.log"
#  if [ $res -ne 1 ]; then
#      echo "[FAIL] $testcase_dir test"
#      exit 1
#  fi
}

#reset_network
# TODO
#channel_create # channel 
run_test

echo "[SUCC]"
exit 0
