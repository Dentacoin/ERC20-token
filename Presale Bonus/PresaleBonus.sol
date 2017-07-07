/*
Dentacoin Foundation Presale Bonus
*/

pragma solidity ^0.4.11;



//Dentacoin token import
contract exToken {
  function transfer(address, uint256) returns (bool) {  }
  function balanceOf(address) constant returns (uint256) {  }
}


// Presale Bonus after Presale
contract PresaleBonus {
  uint public getBonusTime = 14 days;
  uint public startTime;
  address public owner;
  exToken public tokenAddress;
  mapping (address => bool) public requestOf;

  modifier onlyBy(address _account){
    require(msg.sender == _account);
    _;
  }

  function PresaleBonus() {
    owner = msg.sender;
    startTime = now;
    tokenAddress = exToken(0x08d32b0da63e2C3bcF8019c9c5d849d7a9d791e6);
  }

  //Send tiny amount of eth to request DCN bonus
    function () payable {
      if ((startTime + getBonusTime) > now) {
        require(msg.value >= 10);
        require(requestOf[msg.sender] == false);
        requestOf[msg.sender] = true;
      } else {
        require(requestOf[msg.sender]);
        require(tokenAddress.balanceOf(msg.sender) >= 10);
        uint256 bonus = tokenAddress.balanceOf(msg.sender)/10;
        tokenAddress.transfer(msg.sender, bonus);
      }
    }

  // refund to owner
    function refundToOwner () onlyBy(owner) {
        if (!msg.sender.send(this.balance)) {                                        // Send ether to the owner. It's important
            throw;                                                          // To do this last to avoid recursion attacks
        }
        tokenAddress.transfer(owner, tokenAddress.balanceOf(this));
    }






/*
//Send tiny amount of eth to request DCN bonus
  function () payable {
    require((startTime + getBonusTime) > now);
    require(msg.value >= 10);
    require(requestOf[msg.sender] == false);
    requestOf[msg.sender] = true;
  }

  function getBonus() {
    require((startTime + getBonusTime) < now);
    require(requestOf[msg.sender]);
    require(tokenAddress.balanceOf(msg.sender) >= 10);
    bonus = tokenAddress.balanceOf(msg.sender)/10;
    tokenAddress.transfer(msg.sender, bonus);
  }

*/
}
