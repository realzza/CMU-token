pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StudentChargerSharing is ERC20 {

    struct StudentProfile {
        string name;
        string campusEmail;
        uint256 rating;
        uint256 totalRatings;
    }

    struct Charger {
        string description;
        uint256 price;
        address owner;
        bool available;
        bool functional;
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

}

