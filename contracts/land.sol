pragma solidity ^0.5.0;

contract land {

    address public originator;
	uint public propertyid;
	enum Status { NotFound, PendingForApproval, ApprovedForTransactions, ApplicationRejected }

	struct landDetails {
        uint id;   //propertyid
		Status status;
		uint value;
		address currOwner;
        uint size;
        string state;
        string district;
        uint surveyNumber;  //alloted by govt
	}

    // Initializing the User Contract.
	constructor() public  {
		originator = msg.sender;
		users[originator] = 3;
		verifiedUsers[originator] = true;
	}

	mapping(uint => landDetails) public properties;
	mapping(uint => address) public propertiesUnderTxn;
	mapping(uint => bool) public propertyAdded;

    mapping(address => int) public users;   //maps users to level of authority 
    mapping(address => bool) public verifiedUsers;

	function addNewUser(address _newUser) public returns (bool) {
	    require(users[_newUser] == 0);
	    require(verifiedUsers[_newUser] == false);
	    users[_newUser] = 1;
	    return true;
	}


	function addAuthority(address _newAuthority) public verifyHeads returns (bool) {
	    require(users[_newAuthority] == 0);
	    require(verifiedUsers[_newAuthority] == false);
	    users[_newAuthority] = 2;
		verifiedUsers[_newAuthority] = true;
	    return true;
	}

	modifier onlyOwner(uint _propId) {
		require(properties[_propId].currOwner == msg.sender);
		_;
	}

	function approveUsers(address _newUser) verifyAuthority public returns (bool) {
	    require(users[_newUser] != 0);
	    verifiedUsers[_newUser] = true;
	    return true;
	}

	modifier verifyOwner(uint _propId) {
		require(properties[_propId].currOwner == msg.sender);
		_;
	}

	modifier verifyUser(address _user) {
	    require(verifiedUsers[_user]);
	    _;
	}


	modifier verifyAuthority() {
	    require(users[msg.sender] >=2 && verifiedUsers[msg.sender]);
	    _;
	}

	modifier verifyHeads() {
	    require(users[msg.sender] == 3 && verifiedUsers[msg.sender]);
	    _;
	}
	
	modifier propertyExists(uint _survey){
	    require(propertyAdded[_survey] != true);
	    _;
	}



	// Create a new Property.
	function createProperty(uint _value,address _currOwner,uint _size,string memory _state, string memory _district, uint _surveyNumber) public verifyUser(_currOwner) propertyExists(_surveyNumber) returns (bool) {
		propertyid++;
		properties[propertyid] = landDetails(propertyid, Status.PendingForApproval, _value, _currOwner, _size, _state ,_district, _surveyNumber);
		propertyAdded[_surveyNumber] = true;
		return true;
	}


	// Approve the new Property.
	function approveProperty(uint _ID) public verifyAuthority returns (bool){
		require(properties[_ID].currOwner != msg.sender);
		properties[_ID].status = Status.ApprovedForTransactions;
		return true;
	}

	// Reject the new Property.
	function rejectProperty(uint _ID) public  verifyAuthority returns (bool){
		require(properties[_ID].currOwner != msg.sender);
		properties[_ID].status = Status.ApplicationRejected;
		return true;
	}

    	// Price ReEvaluation
    function changeValue(uint _ID, uint _newValue) public verifyOwner(_ID) returns (bool) {
        require(propertiesUnderTxn[_ID] == address(0));
        properties[_ID].value = _newValue;
        return true;
    }


	// Request Sale
	function sale(uint _ID, address _newOwner) public onlyOwner(_ID) verifyUser(_newOwner) returns (bool) {
		require(properties[_ID].currOwner != _newOwner);
		require(propertiesUnderTxn[_ID] == address(0));
		propertiesUnderTxn[_ID] = _newOwner;
		return true;
	}

	// Approve Sale
	function approveSale(uint _ID) verifyAuthority public returns (bool) {
	    require(propertiesUnderTxn[_ID] != address(0));
	    properties[_ID].currOwner = propertiesUnderTxn[_ID];
	    propertiesUnderTxn[_ID] = address(0);
	    return true;
	}


	// PropertyDetails
	function getPropertyDetails(uint _ID) public view returns (Status, uint, address, uint, string memory, string memory, uint) {
		return (properties[_ID].status, properties[_ID].value, properties[_ID].currOwner, properties[_ID].size, properties[_ID].state, properties[_ID].district, properties[_ID].surveyNumber);
	}

	
}