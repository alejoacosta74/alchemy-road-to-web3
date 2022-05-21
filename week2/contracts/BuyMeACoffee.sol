//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// BuyMeACoffee deployed to Goerli at 0x4BFD1dfE0AC9a5e06603CadeD667427b59A55c1C

contract BuyMeACoffee {

    event NewMemo(
        address indexed from,
        uint256 timestamp,
        string name,
        string message
    );
    
    //Memo struct
    struct Memo {
        address from;
        uint256 timestamp;
        string name;
        string message;
    }

    //Memo array
    Memo[] memos;

    //Owner
    address payable owner;

    //Constructor
    constructor () {
        owner = payable(msg.sender);
    }

    /*
    * @dev buy a coffee from contract owner
    * @param _name - name of the person who wants to buy coffee
    * @param _message - message of the person who wants to buy coffee
    */
    
    function buyCoffee (string memory _name, string memory _message) public payable {
        require(msg.value > 0, "Cant buy a coffee with 0 ether");

        //Add memo to contract storage
        memos.push(Memo(
            msg.sender,
            block.timestamp,
            _name,
            _message
        ));

        // Emit a new event when new memo is created
        emit NewMemo(msg.sender, block.timestamp, _name, _message);
    }

    /*
    * @dev transfer ether balance to contract owner
    */
    function withdrawTips() public {
        require(owner.send(address(this).balance), "withdraw failed");
        

    }

    /*
    * @dev retries memos from contract storage
    */
    function getMemos() public view returns (Memo[] memory) {
        return memos;
    }

}
