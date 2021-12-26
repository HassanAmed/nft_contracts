pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

contract Counter {
    uint public count;
    
    function increment() external {
        count += 1;
    }
}