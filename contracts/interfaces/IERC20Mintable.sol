   // SPDX-License-Identifier: MIT
   pragma solidity ^0.8.0;

   import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
   import "./IERC20Mintable.sol";

   contract MintableToken is ERC20, IERC20Mintable {
       constructor(string memory name, string memory symbol)
           ERC20(name, symbol) {}

       function mint(address to, uint256 amount) public override {
           _mint(to, amount);
       }
   }
   
