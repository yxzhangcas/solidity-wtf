// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Yeye {
    event YeyeLog(string msg);

    function hip() public virtual {
        emit YeyeLog("Yeye hip");
    }
    function pop() public virtual {
        emit YeyeLog("Yeye pop");
    }
    function yeye() public virtual {
        emit YeyeLog("Yeye yeye");
    }
}
