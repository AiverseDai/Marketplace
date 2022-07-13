// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Sellers {
    mapping(address => seller) public sellers;
    address[] public List;

    
    struct seller {
        string name;
        string email;
        uint256 mobileNumber;
        address id;
        string name_of_service;
    }

    
    function updateprofile(string memory _name,string memory _email,uint256 _mobile , string memory _name_of_service,address _id) public  {
        sellers[msg.sender].name = _name;
        sellers[msg.sender].email = _email;
        sellers[msg.sender].mobileNumber = _mobile;
        sellers[msg.sender].id = _id;
        sellers[msg.sender].name_of_service = _name_of_service;

    }

   
    function addseller(string memory name, uint mobile, string memory email , string memory name_of_service) public  {
        seller memory newseller;
        newseller.name = name;
        newseller.email  = email;
        newseller.mobileNumber  = mobile;
        newseller.id=msg.sender;
        newseller.name_of_service = name_of_service;
        sellers[msg.sender]=newseller;
        List.push(msg.sender);
    }
}
