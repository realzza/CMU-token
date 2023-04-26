# CMU Charger Hub

CMU Charger Hub is a decentralized charger sharing platform for Carnegie Mellon University students. It allows students to rent chargers and earn tokens for sharing their chargers with others. The platform is built on Ethereum blockchain using Solidity, and the code is based on the OpenZeppelin ERC20 token contract.

## Features

1. **Register Student**: Students register using their name and campus email.
2. **Add Charger**: Charger owners can add their chargers to the platform with a description and price.
3. **Delist Charger**: Charger owners can delist their chargers from the platform.
4. **Request Booking**: Students can request to book a charger.
5. **Confirm Booking**: Charger owners can confirm bookings.
6. **Rate Student**: Students can rate each other.
7. **Report Charger Lost**: Students can report a lost charger.
8. **Report Charger Damaged**: Students can report a damaged charger.
9. **Top-Up Tokens**: Students can top up their token balance using deposited Ether.
10. **Cash Out Tokens**: Students can cash out their tokens for Ether.

## Events

The following events are emitted for various actions on the platform:

- `ChargerAdded`
- `ChargerDelisted`
- `BookingRequest`
- `BookingConfirmed`
- `PaymentTransferred`
- `UserRated`
- `ChargerReportedLost`
- `ChargerReportedDamaged`
- `TokensToppedUp`
- `TokensCashedOut`

## Contracts

The main contract is `StudentChargerSharing`, which extends the OpenZeppelin ERC20 contract. It includes several struct definitions for managing student profiles, chargers, and bookings.

- `StudentProfile`: Represents a student's profile, including their name, campus email, rating, total ratings, deposit, registration status, and token balance.
- `Charger`: Represents a charger, including its description, price, owner, availability, functionality, and damage fine.
- `Booking`: Represents a booking, including the charger ID, renter, start date, end date, and active status.

## Mappings

- `registeredCampusEmails`: A mapping of registered campus emails to their registration status.
- `studentProfiles`: A mapping of student addresses to their respective profiles.
- `chargers`: A mapping of charger IDs to their respective charger details.
- `bookings`: A mapping of booking IDs to their respective booking details.

## Constants

- `deposit`: The required deposit amount in Ether (10 Ether).
- `damageFineInTokens`: The damage fine in tokens (50 tokens).
- `tokenPrice`: The price of one token in Ether (0.01 Ether).

## Constructor

The constructor initializes the ERC20 token contract with a name, symbol, and initial supply.

## Functions

The contract includes various functions for managing student registration, charger sharing, and booking, as well as rating students, reporting lost or damaged chargers, topping up tokens, and cashing out tokens.

Please refer to the source code for the implementation details of each function.

## Security

The contract uses `require` statements to validate function input and ensure that only authorized users can perform certain actions.

## Deployment

To deploy the contract, compile the Solidity code using an appropriate compiler, such as Remix or Truffle, and then deploy the compiled contract to the Ethereum network.

## Dependencies

The contract depends on the OpenZeppelin ERC20 token contract, which is imported at the beginning of the source code. Make sure to include this dependency when compiling and deploying the contract.

