pragma solidity ^0.5.15;

import "ds-test/test.sol";
import "ds-math/math.sol";

import {DarkFix} from "./DarkFix.sol";

import "lib/dss-interfaces/src/dapp/DSPauseAbstract.sol";
import "lib/dss-interfaces/src/dapp/DSChiefAbstract.sol";
import "lib/dss-interfaces/src/dss/MKRAbstract.sol";

contract Hevm {
    function warp(uint256) public;
}

contract DarkFixTest is DSTest, DSMath {
    Hevm hevm;

    // Kovan Release 1.0.2 Deployment Addresses
    DSPauseAbstract pause = DSPauseAbstract(
        0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189
    );
    MKRAbstract gov = MKRAbstract(
        0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD
    );
    DSChiefAbstract chief = DSChiefAbstract(
        0xbBFFC76e94B34F72D96D054b31f6424249c1337d
    );

    // hard-coded variable for now
    bytes public initbytecode = hex"608060405234801561001057600080fd5b5060de8061001f6000396000f3fe6080604052348015600f57600080fd5b506004361060285760003560e01c80636146195414602d575b600080fd5b60336035565b005b7375dd74e8afe8110c8320ed397cccff3b8134d98173ffffffffffffffffffffffffffffffffffffffff166307da68f56040518163ffffffff1660e01b8152600401600060405180830381600087803b158015609057600080fd5b505af115801560a3573d6000803e3d6000fd5b5050505056fea265627a7a723158203d4cd6520e90b5bd48907b326bcad59688a7e33a835157cdec13e46e9523243064736f6c634300050f0032";

    bytes public wrongbytecode = hex"608060405234801561001057600080fd5b5060de8061001f6000396000f3fe6080604052348015600f57600080fd5b506004361060285760003560e01c80636146195414602d575b600080fd5b60336035565b005b7375dd74e8afe8110c8320ed397cccff3b8134d98173ffffffffffffffffffffffffffffffffffffffff166307da68f56040518163ffffffff1660e01b8152600401600060405180830381600087803b158015609057600080fd5b505af115801560a3573d6000803e3d6000fd5b5050505056fea265627a7a723158203d4cd6520e90b5bd48907b326bcad59688a7e33a835157cdec13e46e9523243064736f6c634300050f0033";
    // hard-coded variable for now
    bytes32 public salt = hex"3133333700000000000000000000000000000000000000000000000000000000";

    bytes20 constant CHEAT_CODE = 
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));
        hevm.warp(_NOW_);
    }

    function vote(DarkFix _spell) private {
        if (chief.hat() != address(_spell)) {
            gov.approve(address(chief), uint256(-1));
            chief.lock(sub(gov.balanceOf(address(this)), 1 ether));

            assertTrue(!_spell.done());

            address[] memory yays = new address[](1);
            yays[0] = address(_spell);

            chief.vote(yays);
            chief.lift(address(_spell));
        }
        assertEq(chief.hat(), address(_spell));
    }

    function scheduleWaitAndCast(DarkFix _spell) public {
        _spell.schedule();
        hevm.warp(add(now, pause.delay()));
        _spell.cast(initbytecode, salt);
    }

    function testSpellIsCast_UNIT() public {
        DarkFix spell = DarkFix(_SPELLADDR_);

        vote(spell);
        scheduleWaitAndCast(spell);
        assertTrue(spell.done());
    }

    function testFailSpellIsCastWithWrongBytecode_UNIT() public {
        DarkFix spell = DarkFix(_SPELLADDR_);
        vote(spell);

        spell.schedule();
        hevm.warp(add(now, pause.delay()));
        spell.cast(wrongbytecode, salt);
    }

    function testFailSpellIsCastWithIncorrectSalt() public {
        DarkFix spell = DarkFix(_SPELLADDR_);
        vote(spell);

        spell.schedule();
        hevm.warp(add(now, pause.delay()));
        spell.cast(initbytecode, "abc123");
    }

}
