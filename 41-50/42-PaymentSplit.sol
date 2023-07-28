// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PaymentSplit {
    event PayeeAdded(address amount, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 public totalShares;
    uint256 public totalReleased;

    mapping(address => uint256) public shares;      // 每个受益人的份额
    mapping(address => uint256) public released;    // 支付给受益人的金额
    address[] public payees;                        // 受益人列表

    constructor(address[] memory _payees, uint256[] memory _shares) payable {
        require(_payees.length == _shares.length, "PaymentSplit: payees and shares length mismatch");
        require(_payees.length > 0, "PaymentSplit: no payees");
        for (uint256 i = 0; i < _payees.length; i++) {
            _addPayee(_payees[i], _shares[i]);
        }
    }

    function _addPayee(address _account, uint256 _accountShares) private {
        require(_account != address(0), "PaymentSplit: account is the zero address");
        require(_accountShares > 0, "PaymentSplit: shares are zero");
        require(shares[_account] == 0, "PaymentSplit: account already has shares");

        payees.push(_account);
        shares[_account] = _accountShares;
        totalShares += _accountShares;

        emit PayeeAdded(_account, _accountShares);
    }

    receive() external payable virtual {
        emit PaymentReceived(msg.sender, msg.value);
    }

    // 提取剩余份额
    function release(address payable _account) public virtual {
        require(shares[_account] > 0, "PaymentSplit: account has no shares");
        uint256 payment = releasable(_account);
        require(payment != 0, "PaymentSplit: account is not due payment");
        totalReleased += payment;
        released[_account] += payment;
        _account.transfer(payment);
        emit PaymentReleased(_account, payment);
    }
    // 计算可提取份额
    function releasable(address _account) public view returns (uint256) {
        uint256 totalReceived = address(this).balance + totalReleased;
        return pendingPayment(_account, totalReceived, released[_account]);
    }
    function pendingPayment(address _account, uint256 _totalReceived, uint256 _alreadyReleased) public view returns (uint256) {
        return (_totalReceived * shares[_account]) / totalShares - _alreadyReleased;
    }
}