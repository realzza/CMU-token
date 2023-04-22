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
    function addCharger(string memory description, uint256 price) external { /* ... */ }
    function delistCharger(uint256 chargerId) external { /* ... */ }
    function requestBooking(uint256 chargerId) external { /* ... */ }
    function confirmBooking(uint256 chargerId, address renter, uint256 startDate, uint256 endDate) external { /* ... */ }

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

