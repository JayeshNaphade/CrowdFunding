// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding{
    mapping(address=>uint ) public contributors;
    address public manager;
    uint public MinContribution;
    uint public deadline;
    uint public target;
    uint public RaisedAmount;
    uint public noOfContributors;

    struct request{ // we create a request varaiable for to make request 
        string description;
        uint value;
        address payable recipient; // jo req kr rha he uska address 
        bool completed; //bool chehck krega voting complete hui he ki nhi ya pending he
        uint noOfVoters;
        mapping (address => bool) voters; // ye mapping vo address ko confirm kregi jinlogone contribute kiya he , agr contribute kiya he to vo vote kr skte he 
    }

    mapping (uint=>request)public requests; //for the multiple requests
    uint public numRequests;

    constructor(uint _target , uint _deadline){
        target = _target;
        deadline = block.timestamp +_deadline;
        MinContribution = 100 wei;
        manager = msg.sender;
    }

    function sendETH() public payable{
        require(block.timestamp < deadline , "deadline has passed ");
        require(msg.value >= MinContribution,"minimum contribution is not met");

        if (contributors [msg.sender]== 0 ){
            noOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        RaisedAmount+=msg.value;
    }

    function getContractBal() public view returns (uint){
        return address(this).balance; 

    }

    function refund()public {
        require(block.timestamp< deadline && RaisedAmount > target, "you are not eligible for the refund");
        require ( contributors[msg.sender] < 0 ); //it checks that kuch  perticular value send ki he ki nahi user ne , agr ki he tohii refund denge 
        // mapp kiya tha address ko uint means ether k sath  
        address payable user = payable(msg.sender); 
        user.transfer(100);
        contributors[msg.sender] = 0 ;
    }

    modifier onlyManager(){
        require(msg.sender == manager , "only manager can call this function.");
        _;
    }

    function createRequest(string memory _description , uint _value , address payable _recipient ) public onlyManager{
    // is function ko only manager use kr skta he issliye upr modifier banayaa..

        request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description; // ye sab new request ko fetch krega it means usme agr data likhoge like 
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed == false;
        newRequest.noOfVoters=0;
    }

    function voteRequest(uint _requestNo)public {
        require(contributors[msg.sender]>0 , " you are not contributor");
        request storage thisrequest=requests[_requestNo];
        require(thisrequest.voters[msg.sender]==false, "you have already voted");
        thisrequest.voters[msg.sender]== true;
        thisrequest.noOfVoters++;
    
    }
    function makePayment(uint _requestNo) public onlyManager{
        require(RaisedAmount >= target);
        request storage thisrequest = requests[_requestNo]; //yaha hmne vo pure structure ko call kiyaa ab next line me structure ko indentify krenge apni conditions k hisab se 
        require(thisrequest.completed == false , "the request has been completed");
        require(thisrequest.noOfVoters>noOfContributors/2 , " majority does not support");
        thisrequest.recipient.transfer(thisrequest.value);
        thisrequest.completed==true;
    }
}