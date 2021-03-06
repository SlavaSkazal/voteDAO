// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract voteDAO is ERC20 {
    
    uint minQuorum;
    address chairPerson;
    address voteToken;
    uint index;

    struct Proposal {
        bool voteIsOver;
        bool executeSuccessfully; 
        uint totalTokens; 
        uint voteSupport; 
        uint endTimeOfVote;
        uint supportPercent; 
        string desc;
        bytes transactionByteCode;
        address recepient;
        mapping(address => uint) usedBalance;
    }

    mapping(uint => Proposal) public proposals;
    mapping(address => uint) public balances;
    mapping(address => mapping(uint => address[])) public delegates;

    event AdditionProposal(address indexed tokenOwner, address indexed recepient, string description, uint supportPercent);
    event EndingVote(address indexed tokenOwner, address indexed recepient, string description, bool result);

    constructor(address _chairPerson, address _voteToken, uint _minQuorum) public {
        chairPerson = _chairPerson;
        voteToken = _voteToken;
        minQuorum = _minQuorum;
    }

    modifier onlyChairPerson() {
        require(msg.sender == chairPerson);
        _;
    }

    function deposit(uint amount) public{
        require(amount > 0);
        balances[msg.sender] += amount;
        transferFrom(msg.sender, amount);
    }

    function withdraw(uint amount) public{
        require(balances[msg.sender] >= amount);

        uint usedBalance;

        for (uint i = 0; i < index; i++) {

            if (!proposals[i].voteIsOver && usedBalance < proposals[i].usedBalance[msg.sender]) {
                usedBalance = proposals[i].usedBalance[msg.sender];
            }
        }

        if (amount <= balances[msg.sender] - usedBalance) {
            balances[msg.sender] -= amount;
            transfer(msg.sender, amount);
        }
    }

    function delegate(address confidant, uint index_) external {
        require(index_ < index);
        delegates[confidant][index_].push(msg.sender);
    }

    function changeVoteRules(uint _minQuorum) external onlyChairPerson {
        minQuorum = _minQuorum;
    }

    function addProposal(address _recepient, string memory description, uint _supportPercent, bytes memory _transactionByteCode) external{

        Proposal newProposal = Proposal(false, false, 0, 0, 3 days, _supportPercent, description, _transactionByteCode, _recepient);
        proposals[index] = newProposal;
        index++;

        emit AdditionProposal(msg.sender, _recepient, description, _supportPercent);
    }

    function vote(uint index_, bool supportAgainst) external{

        if (index_ < index && !proposals[index_].voteIsOver) {

            if (balances[msg.sender] > 0) {

                _vote(index_, msg.sender, supportAgainst);

            } else {

                for (uint i = 0; i < delegates[msg.sender][index_].length; i++) {
                    _vote(index_, delegates[msg.sender][index_][i], supportAgainst);
                }
            }
        }
    }

    function _vote(uint index_, address tokenOwner, bool supportAgainst) private{

        if (proposals[index_].usedBalance[tokenOwner] < balances[tokenOwner]) {

            uint unlockBalance = balances[tokenOwner] - proposals[index_].usedBalance[tokenOwner];
            proposals[index_].usedBalance[tokenOwner] += unlockBalance;
            proposals[index_].totalTokens += unlockBalance;

            if (supportAgainst) {
                proposals[index_].voteSupport += unlockBalance;
            }
        }
    }

    function voteFinish(uint index_) external {

        if (index_ < index
            && !proposals[index_].voteIsOver
            && (proposals[index_].totalTokens >= minQuorum
                || proposals[index_].endTimeOfVote <= block.timestamp)) {   

            proposals[index_].voteIsOver = true;

            uint totalSupportPercent = proposals[index_].voteSupport * 100 / proposals[index_].totalTokens;

            if (totalSupportPercent >= proposals[index_].supportPercent) {
                proposals[index_].executeSuccessfully = proposals[index_].recepient.call(proposals[index_].transactionByteCode);
            }
            
            emit EndingVote(msg.sender, proposals[index_].recepient, proposals[index_].desc, proposals[index_].executeSuccessfully);
        } 
    }
}    