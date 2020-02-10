pragma solidity ^0.5.15;

import "ds-math/math.sol";

import "lib/dss-interfaces/src/dapp/DSPauseAbstract.sol";

contract DeployLike {
    function deploy(bytes32, bytes memory) public returns (address);
}

contract DarkFix is DSMath {
    DSPauseAbstract public pause = DSPauseAbstract(
        0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189
    );

    DeployLike public deployer = DeployLike(
        0xe0Ee4f4b3f7A1c8ad1A86949018d6a897DA5EB12
    );

    address public action;
    bytes32 public tag;
    uint256 public eta;
    bytes   public sig;
    bool    public done;

    constructor() public {
        sig = abi.encodeWithSignature(
            "execute()"
        );

        tag = _DEPLOYHASH_;
        action = _CREATE2_;
    }

    function schedule() public {
        require(eta == 0, "spell-already-scheduled");
        eta = add(now, pause.delay());
        pause.plot(action, tag, sig, eta);
    }

    function cast(bytes memory _bytecode, bytes32 _salt) public {
        require(!done, "spell-already-cast");
        done = true;

        deployer.deploy(_salt, _bytecode);
        pause.exec(action, tag, sig, eta);
    }
}
