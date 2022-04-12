pragma solidity ^0.5.0;

contract Rental {

    struct Car {
        string make; // Car Model
        bool isAvailable;  // if true, this car can be rented out
        address rentee; // person delegated to
        address owner; //Owner of Car
        uint year;   // index of the voted proposal
        string licenseNumber; // Car identification
        uint carId; // index of car to be rented 
    }
    
    bool private stopped = false;
    uint totCars = 0;
    address private manager;

     // The constructor. We assign the manager to be the creator of the contract.It could be enhanced to support passing maangement off.
    
    constructor() public  
    {
        manager = msg.sender;
    }

    //Check if sender isAdmin, this function alone could be added to multiple functions for manager only method calls
    modifier isAdmin() {
        assert(msg.sender == manager);
        _;
    }
    


    //Number of Cars available for rent
    Car[] public rentals;                   //*****

    //Return Total Number of Cars
    function getCarCount() public view returns(uint) {
        if(totCars == rentals.length)
        return rentals.length;
        else
        return totCars;
    }

    //Renting a car 
    function rent(uint carId) public returns (bool) {

        Car storage specificCar = rentals[carId];
       
       //Never Ever want to be false, therefore we use assert
       assert(!stopped); 

       require(specificCar.owner != msg.sender);
        
        
       //Validate cardId is within array
      uint totalCars = getCarCount();
      
    //There must be a car to rent and ID # must be within range 
      require(carId >= 0 && carId < totalCars);
    
    //Reference to the car that will be rented 
    Car storage carToBeRented = rentals[carId];         //******

    //Car must be available
    require(carToBeRented.isAvailable == true);
      
      //Assign Rentee to Sender
      carToBeRented.rentee = msg.sender;
      
      //Remove Availability
      carToBeRented.isAvailable = false; 
      
     //Return Success
      return true;
    }

    // Retrieving the car data necessary for user
    function getRentalCarInfo(uint carId) public view returns (string memory make, string memory license, address owner, address rentee, bool available, uint year, uint id) {
      
      uint totalCars = getCarCount();
      require(carId >= 0 && carId < totalCars);
      
      //Get specified car 
      Car memory specificCar = rentals[carId];
      
      //Return data considered in rental process
      return (specificCar.make,specificCar.licenseNumber, specificCar.owner ,specificCar.rentee, specificCar.isAvailable, specificCar.year , specificCar.carId);
    }

    //Add RentableCar
    function addNewCar(string memory make, address owner, string memory licenseNumber, uint year) public returns (uint) {
        assert(!stopped); 
        //Create car object within function
        
        //Current # of cars
        uint count = getCarCount();
        //Increment Count
        //Construct Car Object
        Car memory newCar = Car(make,true, address(0) , owner, year,licenseNumber,count);
        
        //Add to Array
        rentals.push(newCar);

        //Increment total cars 
        totCars += 1;
        
        return count;
    }
    
    //Allow Car Owner to Mark car as returned
    function returnCar(uint carId) public  returns (bool) {
        assert(!stopped); 
        
        //Get Specific car
        Car storage specificCar = rentals[carId];
        require(specificCar.owner == msg.sender);
        //Make car available again
        specificCar.isAvailable = true;
        //Remove previous rentee
        specificCar.rentee = address(0);
        
        //Return Success
        return true;
    }

    function removeCar(uint carId) public returns (bool) {
        assert(!stopped);

        //Get Specific Car
        Car storage specificCar = rentals[carId];
        require(specificCar.owner == msg.sender && specificCar.isAvailable == true);
        //Get total cars listed
        uint n = getCarCount();
        if(carId >= n) return false;

        // Loop to remove car and move elements by 1
        for(uint i = carId; i< n-1 ; i++){
            rentals[i] = rentals[i+1];
        }
        
        // Delete the car with carID
        delete rentals[n-1];
        totCars -=1 ;
        return true;
    }

}