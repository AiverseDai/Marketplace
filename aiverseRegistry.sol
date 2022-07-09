// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.25 <0.9.0;



contract Customers {
    address[] public customerList;
    mapping(address => Customer) public customers;

    // Events

    event CustomerAdded(address id_, string name, string email);
    event CustomerDataUpdated(address id_, string name, string email);
    event DataHashUpdated(address id_, string customerName, string dataHash);

   
    
    struct Customer {
        string name;
        string email;
        uint256 mobileNumber;
        address id_;
    }

    
    function updateprofile(
        string memory name_,
        string memory email_,
        uint256 mobile_
    ) public  {
        customers[msg.sender].name = name_;
        customers[msg.sender].email = email_;
        customers[msg.sender].mobileNumber = mobile_;
        emit CustomerDataUpdated(msg.sender, name_, email_);
    }

   
    function addcustomer(uint mobile, string memory name, string memory email) public  {
        Customer memory newcustomer;
        newcustomer.name = name;
        newcustomer.email  = email;
        newcustomer.mobileNumber  = mobile;
        newcustomer.id_=msg.sender;

        customers[msg.sender]=newcustomer;
        customerList.push(msg.sender);
    }
}