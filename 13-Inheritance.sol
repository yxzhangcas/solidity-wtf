// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// 父合约允许被重写：virtual
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

// 合约继承方式：is
// 子合约进行了重写：override
contract Baba is Yeye {
    function hip() public virtual override {        // 继承
        emit YeyeLog("Baba hip");
    }
    function pop() public virtual override {        // 继承
        emit YeyeLog("Baba pop");
    }
    function baba() public virtual {
        emit YeyeLog("Baba baba");
    }
}

// 多重继承：is <>,<>，按辈分从高到低排列
contract Erzi is Yeye, Baba {
    // 在多个继承合约中都存在的函数必须重写！（hip, pop）
    function hip() public virtual override (Yeye, Baba) {
        emit YeyeLog("Erzi hip");
    }
    function pop() public virtual override (Yeye, Baba) {
        emit YeyeLog("Erzi pop");
    }

    // 直接调用父合约
    function YeyeHip() public {
        Yeye.hip();
    }
    // super关键字：调用最近的父合约，最右
    function BabaHip() public {
        super.hip();
    }
}

// 每一个合约都可以单独部署，但部署完成后只有合约的真正可用内容，不再记录继承关系，也不会部署父合约。
// 例：部署Erzi合约后，有4个成员方法，两个是自己的，另外两个是继承自Yeye和Baba的。