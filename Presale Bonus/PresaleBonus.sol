/*
Dentacoin Foundation Presale Bonus   (Testnet)
*/

pragma solidity ^0.4.11;



//Dentacoin token import
contract exToken {
  function transfer(address, uint256) returns (bool) {  }
  function balanceOf(address) constant returns (uint256) {  }
}


// Presale Bonus after Presale
contract PresaleBonus {
  uint public getBonusTime = 14 minutes;                                      // Time span from contract deployment to end of bonus request period. Afterwards bonus will be paid out
  uint public startTime;                                                      // Time of contract deployment
  address public owner;                                                       // Owner of this contract, who may refund all remaining DCN and ETH
  exToken public tokenAddress;                                                // Address of the DCN token: 0x08d32b0da63e2C3bcF8019c9c5d849d7a9d791e6

  mapping (address => bool) public requestOf;                                 // List of all DCN holders, which requested the bonus
  address[] public receiver;                                                  // Array to iterate threw this receivers and send the bonus to them

  modifier onlyBy(address _account){                                          // All functions modified by this, must only be used by the owner
    require(msg.sender == _account);
    _;
  }

  function PresaleBonus() {                                                   // The function that is run only once at contract deployment
    owner = msg.sender;                                                       // Set the owner address to that account, which deploys this contract
    startTime = now;                                                          // Set the start time of the request period to the contract deployment time
    tokenAddress = exToken(0x571280B600bBc3e2484F8AC80303F033b762048f);       // Define Dentacoin token address
  }

  //Send tiny amount of eth to request DCN bonus
    function () payable {                                                     // This empty function runs by definition if anyone sends ETH to this contract
      if (msg.sender != owner) {                                              // Check if the contract owner sends ETH, which doesn't have any effect
        require((startTime + getBonusTime) > now);                            // If the request period has not ended yet, then do the following:
        require(msg.value < 10 && msg.value >= 1);                            // Check if the requester sends 1-10 Wei to this contract (proof of ownership)
        require(requestOf[msg.sender] == false);                              // Check if the requester didn't request yet
        requestOf[msg.sender] = true;                                         // Finally add the requester to the list of requesters
        receiver.push(msg.sender);
      }
    }



    function sendBonus() onlyBy(owner) {
      require((startTime + getBonusTime) < now);
      for (uint ii = 0; ii < receiver.length-1; ii++) {
        if (requestOf[receiver[ii]] && tokenAddress.balanceOf(receiver[ii]) >= 10) {
          requestOf[receiver[ii]] = false;                                      // Remove the requester from the list of requesters
          uint256 bonus = tokenAddress.balanceOf(receiver[ii])/10;              // Set the bonus amount to 10% of the requesters DCN holdings
          tokenAddress.transfer(receiver[ii], bonus);                           // Transfer the bonus from this contract to the requester
        }
      }
    }




  // refund to owner
    function refundToOwner () onlyBy(owner) {                                 // Send remaining ETH and DCN to the contract owner
        if (!msg.sender.send(this.balance)) {                                 // Send ether to the owner
            throw;
        }
        tokenAddress.transfer(owner, tokenAddress.balanceOf(this));           // Send DCN to the owner
    }
}
