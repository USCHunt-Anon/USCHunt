// : MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)


pragma solidity ^0.4.24;




contract ProxyStorage {
    address public implementation;
}





contract ScoreStorage {

    uint256 public score;

}

contract ScoreV2 is ProxyStorage, ScoreStorage {

    function setScore(uint256 _score) public {
        score = _score + 1;
    }
}