pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;

contract Wallet {
    address[] public approvers;
    uint public quorom;
    struct Transfer {
        uint id;
        uint amount;
        address payable to;
        uint approvals;
        bool sent;
    }

    Transfer[] public transfers;
    mapping(address => mapping(uint => bool)) public approvals;

    constructor(address[] memory _approvers, uint _quorom) public {
        approvers = _approvers;
        quorom = _quorom;
    }

    function getApprovers() external view returns(address[] memory) {
        return approvers;
    }
    function getTransfers() external view returns(Transfer[] memory) {
        return transfers;
    }

    function createTransfer(uint amount, address payable to) external onlyApprover() {
        transfers.push(Transfer(
        transfers.length,
        amount,
        to,
        0,
        false
        ));
    }
    function approveTransfer(uint _id) external onlyApprover() {
            require(transfers[_id].sent == false, "transfer has already been sent");
            require(approvals[msg.sender][_id] == false, "cannot approve transfer twice");

            approvals[msg.sender][_id] = true;
            transfers[_id].approvals++;
            if (transfers[_id].approvals >= quorom ){
                transfers[_id].sent = true;
                address payable to = transfers[_id].to;
                uint amount = transfers[_id].amount;
                to.transfer(amount);
            }
    }

    receive() external payable {}

    modifier onlyApprover(){
        bool allowed = false;
        for(uint i; i < approvers.length; i++){
            if(approvers[i] == msg.sender){
                allowed = true;
            }
        }
        require(allowed == true, "Not approved");
        _;
    }
}