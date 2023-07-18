// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
contract demo{

    struct trip{
        string place ;
        uint budget; //(per person);
        address person;
        uint agreeVotes;
        uint disagreeVotes;
        uint noOfVotes;
        //uint collectedFund;
        bool IsConfirmed;
    }
    address[] public group;
    uint TotalTrips = 0;
    mapping(uint => trip) public AllTrips;
    mapping(uint => mapping(address => bool)) public userVote;
    mapping(address => bool) public userShare;
    trip public st;
    trip public selectedTrip;
    uint public selectedTripId;

    constructor( address[] memory friends){
        group = friends;
    }

    function checkUserExists(address u) internal view returns(bool){
        for(uint i = 0 ; i < group.length ; i++){
            if(group[i] == u){
                return true;
            }	
        }
        return false;	
    }

    function checkTripExists(string memory name) internal view returns(bool){
        for (uint i = 0; i < TotalTrips; i++) {
            uint tripId = i; // Assuming trip IDs start from 0
            trip memory currentTrip = AllTrips[tripId];
                if (keccak256(bytes(currentTrip.place)) == keccak256(bytes(name))) {
                    return true; // Trip with the given name already exists
                }
        }               
        return false;
        
    }

    function planTrip(string memory _place, uint _budget ) public {
        require(bytes(_place).length>0 , "Enter valid name");
        require(_budget >= 1 ether , "Enter valid budget value");
        require(checkUserExists(msg.sender) , "You are not a part of group");
        require(!checkTripExists(_place) , "Trips already exists");
        TotalTrips++;
        trip memory newTrip = trip(_place , _budget , msg.sender , 0, 0, 0, false);
        AllTrips[TotalTrips] = newTrip;
        
    }

    function Vote(uint tripId , uint v) public{
        require(checkUserExists(msg.sender) , "You are not a part of group");
        require(v == 0 || v == 1 , "Enter 1 to agree/yes or Enter 0 to disagree/no");
        trip storage t = AllTrips[tripId];
        require(bytes(t.place).length > 0 , "Trip doesn't exists");
        require(t.budget > 0 , "Trip budget should be greater than 0");
        require(userVote[tripId][msg.sender] == false , "Already voted");
        require(t.IsConfirmed == false, "Trip  has already been confirmed");
        if( v == 0){
            t.noOfVotes++;
            t.disagreeVotes++;
        }
        else{
            t.noOfVotes++;
            t.agreeVotes++;
        }
        userVote[tripId][msg.sender] = true;
    }

    function CheckTripDestination() public returns(uint ,trip memory){
        require(checkUserExists(msg.sender) , "You are not a part of group");
        require(TotalTrips > 0 , "No trip added");
        trip memory t = AllTrips[0];
        uint confirmedTripId = 0;
        uint highestVotes = 0;
        for(uint i = 0 ; i < TotalTrips ; i++){
            if(AllTrips[i].agreeVotes > highestVotes){
                highestVotes = AllTrips[i].agreeVotes;
                t = AllTrips[i];
                confirmedTripId = i;
            }
        }
        selectedTripId = confirmedTripId;
        selectedTrip = t;
        return (confirmedTripId, AllTrips[confirmedTripId]);
    }

    function payYourShare() public payable{
        require(checkUserExists(msg.sender), "You are not a part of the group");
            require(selectedTrip.budget > 0, "No trip selected");
            require(msg.value >= selectedTrip.budget, "Enter valid amount");
        require(userVote[selectedTripId][msg.sender]== false , "You have already contributed");
        userVote[selectedTripId][msg.sender] = true;
        userShare[msg.sender] = true;
        
    }
}
