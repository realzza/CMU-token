pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StudentChargerSharing is ERC20 {

    struct StudentProfile {
        string name;
        string campusEmail;
        uint256 rating;
        uint256 totalRatings;
        uint256 deposit;
        bool registered;
        uint256 tokens;
    }

    struct Charger {
        string description;
        uint256 price;
        address owner;
        bool available;
        bool functional;
        uint256 damageFine;
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

    // Constants
    uint256 public constant deposit = 10 ether; // Deposit in Ether
    uint256 public constant damageFineInTokens = 50; // Damage fine of 50 tokens
    uint256 public constant tokenPrice = 0.01 ether; // 1 token costs 0.01 ether

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
        chargers[chargerCounter] = Charger(description, price, msg.sender, true, true, damageFineInTokens);
        emit ChargerAdded(chargerCounter, description, price, msg.sender);
    }

    // Delist charger
    function delistCharger(uint256 chargerId) external {
        require(chargers[chargerId].owner == msg.sender, "Only the owner can delist a charger.");
        chargers[chargerId].available = false;
        emit ChargerDelisted(chargerId, msg.sender);
    }

    // Request booking
    // Request booking
    function requestBooking(uint256 chargerId) external {
        require(chargers[chargerId].available, "Charger is not available for booking.");
        require(chargers[chargerId].functional, "Charger is not functional.");
        
        // Check if the requester has enough tokens
        uint256 paymentAmount = chargers[chargerId].price;
        StudentProfile storage requesterProfile = studentProfiles[msg.sender];
        require(requesterProfile.tokens >= paymentAmount, "Insufficient token balance.");

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

        // Rent charger
        uint256 paymentAmount = charger.price;
        StudentProfile storage renterProfile = studentProfiles[booking.renter];
        require(renterProfile.tokens >= paymentAmount, "Insufficient token balance.");

        renterProfile.tokens -= paymentAmount;
        studentProfiles[charger.owner].tokens += paymentAmount;
        emit PaymentTransferred(booking.renter, charger.owner, paymentAmount);

        emit BookingConfirmed(booking.chargerId, booking.renter, startDate, endDate);
    }

    // Register student
    // Updated registerStudent function
    function registerStudent(string memory name, string memory campusEmail) external {
        require(!registeredCampusEmails[campusEmail], "Student with this campus email already registered.");
        require(!studentProfiles[msg.sender].registered, "Account already registered a student.");
        studentProfiles[msg.sender] = StudentProfile(name, campusEmail, 0, 0, deposit, true, 0); // Set initial token balance to 0
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
        uint256 priceInTokens = chargers[chargerId].price * tokenPrice;
        StudentProfile storage reporterProfile = studentProfiles[msg.sender];
        
        require(reporterProfile.tokens >= priceInTokens, "Insufficient tokens for lost charger payment.");
        chargers[chargerId].functional = false;
        reporterProfile.tokens -= priceInTokens;
        studentProfiles[chargers[chargerId].owner].tokens += priceInTokens;
        emit PaymentTransferred(msg.sender, chargers[chargerId].owner, priceInTokens);
        
        emit ChargerReportedLost(chargerId, msg.sender);
    }

    // Report charger damaged
    function reportChargerDamaged(uint256 chargerId) external {
        StudentProfile storage reporterProfile = studentProfiles[msg.sender];
        
        require(reporterProfile.tokens >= damageFineInTokens, "Insufficient tokens for damage fine payment.");
        chargers[chargerId].functional = false;
        reporterProfile.tokens -= damageFineInTokens;
        studentProfiles[chargers[chargerId].owner].tokens += damageFineInTokens;
        emit PaymentTransferred(msg.sender, chargers[chargerId].owner, damageFineInTokens);
        
        emit ChargerReportedDamaged(chargerId, msg.sender);
    }

    // Updated topUpTokens function
    function topUpTokens(uint256 tokenAmount) external payable {
        uint256 etherAmount = tokenAmount * tokenPrice;
        // require(msg.value == etherAmount, "Incorrect Ether amount sent.");
        require(studentProfiles[msg.sender].deposit >= etherAmount, "Insufficient deposit balance for top-up.");
        studentProfiles[msg.sender].tokens += tokenAmount;
        studentProfiles[msg.sender].deposit -= etherAmount;
        emit TokensToppedUp(msg.sender, tokenAmount);
    }


    // New function to check remaining tokens
    function remainingTokens(address student) external view returns (uint256) {
        return studentProfiles[student].tokens;
    }
    
    // New function to check remaining ethers in the deposit (demonstration purpose only)
    function remainingEthers(address student) external view returns (uint256) {
        return studentProfiles[student].deposit / 1e18;
    }

    // Cash out tokens
    function cashOutTokens(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient tokens");
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount * tokenPrice);
        emit TokensCashedOut(msg.sender, amount);
    }
}