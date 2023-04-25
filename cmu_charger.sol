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

    mapping(string => bool) public registeredCampusEmails;
    mapping(address => StudentProfile) public studentProfiles;
    mapping(uint256 => Charger) public chargers;
    mapping(uint256 => Booking) public bookings;
    uint256 private chargerCounter;
    uint256 private bookingCounter;
    
    mapping(address => uint256) public balances;
    mapping(address => bool) public rented;
    mapping(address => uint) public tokens;

    // Constants
    uint256 public constant deposit = 1 ether;
    uint256 public constant rentalFee = 0.25 ether;
    // uint256 public constant damageFine = 0.5 ether;
    uint256 public damageFine;
    uint256 public constant tokenPrice = 0.01 ether; 

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

    // Add charger
    function addCharger(string memory description, uint256 price) external {
        chargerCounter++;
        chargers[chargerCounter] = Charger(description, price, msg.sender, true, true, rentalFee, damageFine, tokenPrice);
        emit ChargerAdded(chargerCounter, description, price, msg.sender);
    }

    // Delist charger
    function delistCharger(uint256 chargerId) external {
        require(chargers[chargerId].owner == msg.sender, "Only the owner can delist a charger.");
        chargers[chargerId].available = false;
        emit ChargerDelisted(chargerId, msg.sender);
    }

    // Request booking
    function requestBooking(uint256 chargerId) external {
        require(chargers[chargerId].available, "Charger is not available for booking.");
        require(chargers[chargerId].functional, "Charger is not functional.");
        bookingCounter++;
        bookings[bookingCounter] = Booking(chargerId, msg.sender, 0, 0, false);
        emit BookingRequest(chargerId, msg.sender);
    }

    // Confirm booking
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

    // Transfer payment
    function transferPayment(address to, uint256 amount) public {
        require(tokens[msg.sender] >= amount, "Insufficient tokens for transfer");
        tokens[msg.sender] -= amount;
        tokens[to] += amount;
        emit PaymentTransferred(msg.sender, to, amount);
    }

    // Register student
    function registerStudent(string memory name, string memory campusEmail) external {
        require(!registeredCampusEmails[campusEmail], "Student with this campus email already registered.");
        studentProfiles[msg.sender] = StudentProfile(name, campusEmail, 0, 0, deposit);
        registeredCampusEmails[campusEmail] = true;
    }


    // Rate student
    function rateStudent(address student, uint256 rating) external { 
        require(bytes(studentProfiles[msg.sender].name).length != 0, "Student is not registered");

        uint256 num_rating = studentProfiles[student].totalRatings;
        uint256 new_rate = (studentProfiles[student].rating * num_rating + rating) / (num_rating + 1);
    
        studentProfiles[student].rating = new_rate;
        studentProfiles[student].totalRatings = num_rating + 1;
        emit UserRated(msg.sender, student, rating);
    }

    // Report charger lost
    function reportChargerLost(uint256 chargerId) external { 
        uint256 price = chargers[chargerId].price;
        uint256 token_price = chargers[chargerId].tokenPrice;
        
        if (balances[msg.sender] >= price) {
            chargers[chargerId].functional = false;
            balances[msg.sender] -= price;
            address owner = chargers[chargerId].owner;
            transferPayment(owner, price / token_price);
        } else {
            studentProfiles[msg.sender].deposit -= price;
            address owner = chargers[chargerId].owner;
            transferPayment(owner, price / token_price);
        }
            
        emit ChargerReportedLost(chargerId, msg.sender);
    }

    // Report charger damaged
    function reportChargerDamaged(uint256 chargerId) external { 
        uint256 damageFine = chargers[chargerId].damageFine;
        uint256 token_price = chargers[chargerId].tokenPrice;
        
        if (balances[msg.sender] >= damageFine) {
            chargers[chargerId].functional = false;
            balances[msg.sender] -= damageFine;
            address owner = chargers[chargerId].owner;
            transferPayment(owner, damageFine / token_price);
        } else {
            studentProfiles[msg.sender].deposit -= damageFine;
            address owner = chargers[chargerId].owner;
            transferPayment(owner, damageFine / token_price);
        }
        
        emit ChargerReportedDamaged(chargerId, msg.sender);
    }

    // Top up tokens
    function topUpTokens(uint256 amount) external payable {
        uint256 etherAmount = amount * (10 ** uint256(decimals()));
        require(msg.value >= etherAmount, "Insufficient Ether sent for top-up.");
        _mint(msg.sender, etherAmount);
        emit TokensToppedUp(msg.sender, etherAmount);
    }
    
    // Cash out tokens
    function cashOutTokens(uint256 amount) external {
        require(tokens[msg.sender] >= amount, "Insufficient tokens");
        tokens[msg.sender] -= amount;
        payable(msg.sender).transfer(amount * tokenPrice);
        emit TokensCashedOut(msg.sender, amount);
    }

    // Rent charger
    function rent(uint256 chargerId, uint256 bookingId) external {
        require(chargers[chargerId].available, "Charger is not available for booking.");
        require(chargers[chargerId].functional, "Charger is not functional.");
        require(bookings[bookingId].isActive, "Booking is not active.");
        require(bookings[bookingId].chargerId == chargerId, "Invalid charger for this booking.");
        require(bookings[bookingId].renter == msg.sender, "Only the renter can rent the charger.");

        uint256 paymentAmount = chargers[chargerId].price;
        require(balanceOf(msg.sender) >= paymentAmount, "Insufficient token balance.");

        transfer(chargers[chargerId].owner, paymentAmount);
        emit PaymentTransferred(msg.sender, chargers[chargerId].owner, paymentAmount);
    }


    // Return charger
    function returnCharger(bool damaged) external {
        require(rented[msg.sender], "Not rented");
        uint256 balance = balances[msg.sender];
        balances[msg.sender] = 0;
        rented[msg.sender] = false;
        uint256 refund = balance - rentalFee;
        if (damaged) {
            require(refund >= damageFine, "Insufficient balance for damage fee");
            refund -= damageFine;
            payable(msg.sender).transfer(damageFine);
        }
        tokens[msg.sender] += refund / tokenPrice;
    }
}
