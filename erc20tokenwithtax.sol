// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract KudoszoneTokens is ERC20 {
    address admin;
    uint256 public diployedtime;
    uint256 constant TaxResurve = 20000000 * 10**18;
    uint256 private MintedTaxTokens;

    constructor() ERC20("sampletoken", "CDOS") {
        _mint(msg.sender, 400000000 * (10**uint256(decimals())));
        admin = msg.sender;
        diployedtime = block.timestamp;
    }

    function ClaimTaxTokens(uint256 amt, address to) public returns (bool) {
        require(msg.sender == admin, "only admin");
        require(
            block.timestamp > diployedtime + 2592000,
            "Claiming cliff is 30days"
        );
        require(MintedTaxTokens + amt <= TaxResurve, "Taxlimit reached");
        _mint(to, amt * (10**uint256(decimals())));
        MintedTaxTokens = MintedTaxTokens + amt;
        return true;
    }
}
