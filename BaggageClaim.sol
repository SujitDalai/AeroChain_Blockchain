//----------------------------------------------------------------------------

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.24;

//Contract
//----------------------------------------------------------------------------

contract BaggageClaim{

    address airportAuthority;
    uint public myBalance;
    string private _name;
    string private _symbol;

    struct details{
        uint status;
        uint hashOfDetails;
    }

    struct Memeberships{
        uint memebershipStatus;//0 new, //1-airport,//2-authority//3-customer
    }

    struct Airports{
        address airportAddress;
        uint airportIndex;
    }

    struct AirportBaggage{
        uint timestamp;
        uint pricePerbag;
        uint totalBaggage;
        uint totalUnclaimedBaggage;
        uint totalBaggageClaimed;
    }

    struct ClaimRequest{
        uint requestStatus;
        uint requestQuantity;
        uint amount;
    }

    mapping (address => details) balanceDetails;
    mapping(address => AirportBaggage) airportBaggage;
    mapping(uint => ClaimRequest) claimRequest;
    mapping(address => Memeberships) memberships;
    
    Airports[] airportNames;


// Modifiers  
//-----------------------------------------------------------------------------
   
    modifier onlyAirportAuthority(){
        require(msg.sender == airportAuthority);
        _;
    }

    modifier onlyAirport(){
        require(memberships[msg.sender].memebershipStatus==1);
        _;
    }

    modifier onlyCustomer(){
        require(memberships[msg.sender].memebershipStatus!=1);
        require(memberships[msg.sender].memebershipStatus!=2);
        _;
    }

   
//


//Constructor
//-----------------------------------------------------------------------------  
    
    constructor ()  public{
           _name = 'Baggage Claim';
        _symbol = 'CUB';
        //_totalSupply=10000;
        //_balances[msg.sender] = _totalSupply;

        airportAuthority = msg.sender;
        // balanceDetails[msg.sender].escrow = msg.value;
        memberships[msg.sender].memebershipStatus = 2;
        //myBalance = address(this).balance;
    }
  
  
//
    event LogMessage(string message, uint value);



// Airport functions 


    function registerAirports(uint airportIndex, uint pricePerbag) public{
        if(msg.sender==airportAuthority){
            revert();
        }
        if(memberships[msg.sender].memebershipStatus==3){
            revert();
        }
        address newAirports =msg.sender;
        airportBaggage[newAirports].timestamp = block.timestamp;
        memberships[newAirports].memebershipStatus = 1;
        airportBaggage[newAirports].pricePerbag = pricePerbag;
        airportBaggage[newAirports].totalBaggage = 0;
        airportBaggage[newAirports].totalBaggageClaimed = 0;
        airportBaggage[newAirports].totalUnclaimedBaggage = 0;
        airportNames.push(Airports(newAirports, airportIndex));
    }

   

    function addBaggaage(uint noOfBaggage) public onlyAirport{
        airportBaggage[msg.sender].totalBaggage+=noOfBaggage;
        airportBaggage[msg.sender].totalUnclaimedBaggage+=noOfBaggage;

    }


    function responseToClaimBaggage(uint done, uint hashOfDetails) public onlyAirport{
        if(claimRequest[hashOfDetails].requestStatus!=1){
            revert();
        }
        balanceDetails[msg.sender].status = done;
        balanceDetails[msg.sender].hashOfDetails = hashOfDetails;
        claimRequest[hashOfDetails].requestStatus = done;
    }



//

// Customer functions 
   //-----------------------------------------------------------------------------
     

   function registerCustomer() public{
        if(msg.sender==airportAuthority){
            revert();
        }
        if(memberships[msg.sender].memebershipStatus==1){
            revert();
        }
        address customer =msg.sender;
        memberships[customer].memebershipStatus = 3;


    // _approve(airportAuthority,customer, 100);

    // transferFrom(airportAuthority, customer, 100);


    }

    function requestToClaimBaggage(address fromAirport, uint hashOfDetails, uint noOfBaggage) public  onlyCustomer{
        uint totalAmountNeeded = (airportBaggage[fromAirport].pricePerbag)*noOfBaggage;
        if(airportBaggage[fromAirport].totalUnclaimedBaggage<noOfBaggage){
            revert();
        }
        if(memberships[fromAirport].memebershipStatus!=1){
            revert();
        }
       // if(totalAmountNeeded > balanceOf()){
       //     revert();
       // }

        address newBuyer = msg.sender;
        balanceDetails[newBuyer].status = 1;



  
        balanceDetails[msg.sender].hashOfDetails = hashOfDetails;
        claimRequest[hashOfDetails].requestStatus = 1;

        claimRequest[hashOfDetails].requestQuantity = noOfBaggage;

    }

    function settlePayment(address  toAirport, uint hashOfDetails) public  onlyCustomer{
        uint quantity = claimRequest[hashOfDetails].requestQuantity;
        uint amt = quantity * airportBaggage[toAirport].pricePerbag;
        emit LogMessage("Payment of ", amt);
        emit LogMessage("Payment of airport sent ", amt);
        // if(balanceOf()<amt){
        //     revert();
        // }
        // if(claimRequest[hashOfDetails].requestStatus!=2){
        //     revert();
        // }

        address customer = msg.sender;
        //_transfer(customer, toAirport, amt);

        airportBaggage[toAirport].totalBaggage = airportBaggage[toAirport].totalBaggage-quantity;
        airportBaggage[toAirport].totalUnclaimedBaggage = airportBaggage[toAirport].totalUnclaimedBaggage-quantity;
        airportBaggage[toAirport].totalBaggageClaimed+= airportBaggage[toAirport].totalBaggageClaimed+quantity;
        balanceDetails[toAirport].hashOfDetails = hashOfDetails;


    }



//  functions to read data    
  

    function getTotalUnclaimedBaggage() public view returns(uint){
        return airportBaggage[msg.sender].totalUnclaimedBaggage;
    }

    function getAirportClaimedBagagge() public view returns(uint){
        return airportBaggage[msg.sender].totalBaggageClaimed;
    }

    function getAirportsCount() public view returns(uint){
        return airportNames.length;
    }

    function getAirportsIndex(uint index) public view returns(uint){
        return airportNames[index].airportIndex;
    }

    function getAirportsAddress(uint index) public view returns(address){
        return airportNames[index].airportAddress;
    }

    function getAirportPricePerBag() public view returns(uint){
        return airportBaggage[msg.sender].pricePerbag;
    }

    function getMembershipStatus() public view returns(uint){
        return memberships[msg.sender].memebershipStatus;
    }

    function removeAirportEntry(uint index) public{
        airportNames[index] = airportNames[airportNames.length - 1];
        airportNames.pop();
    }
    

}