#!/usr/bin/env bash

export DAPP_TEST_ADDRESS=0xdB33dFD3D61308C33C63209845DaD3e6bfb2c674
export PAUSE=0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189
export DEPLOYER=0xe0Ee4f4b3f7A1c8ad1A86949018d6a897DA5EB12

export INIT_BYTECODE="608060405234801561001057600080fd5b5060de8061001f6000396000f3fe6080604052348015600f57600080fd5b506004361060285760003560e01c80636146195414602d575b600080fd5b60336035565b005b7375dd74e8afe8110c8320ed397cccff3b8134d98173ffffffffffffffffffffffffffffffffffffffff166307da68f56040518163ffffffff1660e01b8152600401600060405180830381600087803b158015609057600080fd5b505af115801560a3573d6000803e3d6000fd5b5050505056fea265627a7a723158203d4cd6520e90b5bd48907b326bcad59688a7e33a835157cdec13e46e9523243064736f6c634300050f0032"
export RUNTIME_BYTECODE="6080604052348015600f57600080fd5b506004361060285760003560e01c80636146195414602d575b600080fd5b60336035565b005b7375dd74e8afe8110c8320ed397cccff3b8134d98173ffffffffffffffffffffffffffffffffffffffff166307da68f56040518163ffffffff1660e01b8152600401600060405180830381600087803b158015609057600080fd5b505af115801560a3573d6000803e3d6000fd5b5050505056fea265627a7a723158203d4cd6520e90b5bd48907b326bcad59688a7e33a835157cdec13e46e9523243064736f6c634300050f0032"

export SALT=0x3133333700000000000000000000000000000000000000000000000000000000

SPELL="DarkFix"
SPELLFILE="${SPELL}.sol"
TESTFILE="${SPELL}.t.sol"
BUILT_SPELL="./src/${SPELLFILE}"
BUILT_TEST_SPELL="./src/${TESTFILE}"

now=$(date +%s)

cp $SPELLFILE $BUILT_SPELL

create2addr=$(seth --to-checksum-address $(seth call $DEPLOYER\
    'computeAddress(bytes32,bytes)(address)'\
    $(seth --to-bytes32 $SALT)\
    $INIT_BYTECODE\
    )
)

bytecodehash=$(seth --to-bytes32 $(seth call $DEPLOYER\
    'getHash(bytes)(bytes32)' ${RUNTIME_BYTECODE}))

OS=`uname`

if [[ $OS == "Darwin" ]]; then
    sed -i "" -e "s/_CREATE2_/${create2addr}/g" $BUILT_SPELL
    sed -i "" -e "s/_DEPLOYHASH_/0x${bytecodehash}/g" $BUILT_SPELL
else
    sed -i -e "s/_CREATE2_/${create2addr}/g" $BUILT_SPELL
    sed -i -e "s/_DEPLOYHASH_/0x${bytecodehash}/g" $BUILT_SPELL
fi

dapp update
dapp build --extract

spell_addr=$(seth --to-checksum-address $(dapp create --verify $SPELL))

cp $TESTFILE $BUILT_TEST_SPELL

if [[ $OS == "Darwin" ]]; then
    sed -i "" -e "s/_SPELLADDR_/${spell_addr}/g" $BUILT_TEST_SPELL
    sed -i "" -e "s/_NOW_/${now}/g" $BUILT_TEST_SPELL
else
    sed -i -e "s/_SPELLADDR_/${spell_addr}/g" $BUILT_TEST_SPELL
    sed -i -e "s/_NOW_/${now}/g" $BUILT_TEST_SPELL
fi

export LANG=C.UTF-8
dapp update
dapp build --extract

hevm dapp-test --rpc="$ETH_RPC_URL" --json-file=out/dapp.sol.json \
    --dapp-root=. --verbose 1

rm src/*.sol
