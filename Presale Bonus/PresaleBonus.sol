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
    owner = msg.sender;                                                       // Set the owner address to the account which deploys this contract
    startTime = now;                                                          // Set the start time of the request period to the contract deployment time
    tokenAddress = exToken(0x571280B600bBc3e2484F8AC80303F033b762048f);       // Define Dentacoin token address
  }

  //Send tiny amount of eth to request DCN bonus
    function () payable {                                                     // This empty function runs by definition if anyone sends ETH to this contract
      if (msg.sender != owner) {                                              // Check if the contract owner sends ETH, which shouldn't have any effect
        require((startTime + getBonusTime) > now);                            // Make sure that the request period has not ended yet
        require(msg.value < 1000000000000000 && msg.value >= 1);              // Make sure that the requester sends 1 Wei - 0,001 ETH to this contract (proof of ownership)
        require(requestOf[msg.sender] == false);                              // Make sure that the requester didn't request yet
        requestOf[msg.sender] = true;                                         // Finally add the requester to the list of requesters
        receiver.push(msg.sender);                                            // And add the requester to the array of receivers
      }
    }



    function sendBonus() onlyBy(owner) {
      require((startTime + getBonusTime) < now);                              // Make sure that the request period has ended
      for (uint i = 0; i < receiver.length-1; i++) {                          // Iterate threw the list of receivers TODO: check iteration
        if (requestOf[receiver[i]] && tokenAddress.balanceOf(receiver[i]) >= 200) { // TODO: First check needed? AND: try with balance 21 and 39!
          requestOf[receiver[i]] = false;                                      // Remove the requester from the list of requesters
          uint256 bonus = tokenAddress.balanceOf(receiver[i])/20;              // Set the bonus amount to 5% of the requesters DCN holdings
          tokenAddress.transfer(receiver[i], bonus);                           // Transfer the bonus from this contract to the requester
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




    // web3 getter functions
    function receiverID(uint256 _id) constant returns (address receiver) {
            return receiver[_id];
        }
    function balanceOf(address _owner) constant returns (uint256 balance) {
            return tokenAddress.balanceOf(_owner);
        }

}
