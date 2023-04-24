pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StudentChargerSharing is ERC20 {

    struct StudentProfile {
        string name;
        string campusEmail;
        uint256 rating;
        uint256 totalRatings;
        
        uint256 deposit;
    }

    struct Charger {
        string description;
        uint256 price;
        address owner;
        bool available;
        bool functional;
       
        uint256 rentalFee;
        uint256 damageFine;
        uint256 tokenPrice;
    }

    struct Booking {
        uint256 chargerId;
        address renter;
        uint256 startDate;
        uint256 endDate;
        bool isActive;
    }

    mapping(address => StudentProfile) public studentProfiles;
    mapping(uint256 => Charger) public chargers;
    mapping(uint256 => Booking) public bookings;
    uint256 private chargerCounter;
    uint256 private bookingCounter;
    
    mapping(address => uint256) public balances;
    mapping(address => bool) public rented;
    mapping(address => uint) public tokens;

    // Events
    event ChargerAdded(uint256 indexed chargerId, string description, uint256 price, address indexed owner);
    event ChargerDelisted(uint256 indexed chargerId, address indexed owner);
    event BookingRequest(uint256 indexed chargerId, address indexed renter);
    event BookingConfirmed(uint256 indexed chargerId, address indexed renter, uint256 startDate, uint256 endDate);
    event PaymentTransferred(address indexed from, address indexed to, uint256 amount);
    event UserRated(address indexed rater, address indexed ratedUser, uint256 rating);
    event ChargerReportedLost(uint256 indexed chargerId, address indexed reporter);
    event ChargerReportedDamaged(uint256 indexed chargerId, address indexed reporter);
    event TokensToppedUp(address indexed user, uint256 amount);
    event TokensCashedOut(address indexed user, uint256 amount);
    
   
    // Constructor
    constructor() ERC20("StudentChargerToken", "SCT") {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }

    // Ziang's functions
    function addCharger(string memory description, uint256 price) external {
        chargerCounter++;
        chargers[chargerCounter] = Charger(description, price, msg.sender, true, true);
        emit ChargerAdded(chargerCounter, description, price, msg.sender);
    }

    function delistCharger(uint256 chargerId) external {
        require(chargers[chargerId].owner == msg.sender, "Only the owner can delist a charger.");
        chargers[chargerId].available = false;
        emit ChargerDelisted(chargerId, msg.sender);
    }

    function requestBooking(uint256 chargerId) external {
        require(chargers[chargerId].available, "Charger is not available for booking.");
        require(chargers[chargerId].functional, "Charger is not functional.");
        bookingCounter++;
        bookings[bookingCounter] = Booking(chargerId, msg.sender, 0, 0, false);
        emit BookingRequest(chargerId, msg.sender);
    }

    function confirmBooking(uint256 bookingId, uint256 startDate, uint256 endDate) external {
        Booking storage booking = bookings[bookingId];
        Charger storage charger = chargers[booking.chargerId];
        require(charger.owner == msg.sender, "Only the owner can confirm a booking.");
        require(!booking.isActive, "Booking is already confirmed.");
        require(charger.available, "Charger is not available for booking.");
        require(charger.functional, "Charger is not functional.");
        require(startDate < endDate, "Invalid booking dates.");

        booking.startDate = startDate;
        booking.endDate = endDate;
        booking.isActive = true;
        charger.available = false;

        emit BookingConfirmed(booking.chargerId, booking.renter, startDate, endDate);
    }

    // Mia's function
    function transferPayment(address to, uint256 amount) external { /* ... */ }
    function registerStudent(string memory name, string memory campusEmail) external { /* ... */ }

    // Jenny's functions
    function returnCharger(uint256 chargerId) external { /* ... */ }
    function rateStudent(address student, uint256 rating) external { /* ... */ }
    function reportChargerLost(uint256 chargerId) external { /* ... */ }
    function reportChargerDamaged(uint256 chargerId) external { /* ... */ }

    // Chloris's functions
    function topUpTokens(uint256 amount) external { /* ... */ }
    function cashOutTokens(uint256 amount) external { /* ... */ }
    
    constructor() {
        owner = msg.sender;
        deposit = 1 ether;
        rentalFee = 0.25 ether;
        damageFine = 0.5 ether;
        tokenPrice = 0.01 ether; 
    }

   function topUpTokens(uint256 amount) external {
        require(msg.value == amount * tokenPrice, "Incorrect token price, cannot be topped up");
        tokens[msg.sender] += amount;
        emit TokensToppedUp(msg.sender, amount);
    }
    
    function cashOutTokens(uint256 amount) external {
        require(tokens[msg.sender] >= amount, "Insufficient tokens");
        tokens[msg.sender] -= amount;
        payable(msg.sender).transfer(amount * tokenPrice);
        emit TokensCashedOut(msg.sender, amount);
    }
}

    function rent() external payable {
        require(msg.value >= deposit + rentalFee, "Insufficient funds");
        require(!rented[msg.sender], "Already rented,cannot rent again");
        balances[msg.sender] = msg.value;
        rented[msg.sender] = true;
    }

    function returnCharger(bool damaged) external {
        require(rented[msg.sender], "Not rented");
        uint balance = balances[msg.sender];
        balances[msg.sender] = 0;
        rented[msg.sender] = false;
        uint refund = balance - rentalFee;
        if (damaged) {
            require(refund >= damageFine, "Insufficient balance for damage fee");
            refund -= damageFine;
            owner.transfer(damageFine);
        }
        tokens[msg.sender] += refund / tokenPrice;
    }
}

