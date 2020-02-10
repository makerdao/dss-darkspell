pragma solidity ^0.5.0;

contract Create2 {

    function deploy(bytes32 salt, bytes memory bytecode) 
        public
        returns (address) 
    {
        address addr;
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes memory bytecode) 
        public
        view 
        returns (address) 
    {
        return computeAddress(salt, bytecode, address(this));
    }

    function computeAddress(bytes32 salt, bytes memory bytecodeHash, address deployer) 
        public
        pure 
        returns (address) 
    {
        bytes32 bytecodeHashHash = keccak256(bytecodeHash);
        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHashHash)
        );
        return address(bytes20(_data << 96));
    }

    function getHash(bytes memory bytecode)
        public
        pure
        returns (bytes32)
    {
        return keccak256(bytecode);
    }
}
