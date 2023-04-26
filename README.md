# CMU Charger Hub

CMU Charger Hub is a decentralized charger sharing platform for Carnegie Mellon University students. It enables students to rent chargers and earn tokens by sharing their chargers with others. The platform is built on the Ethereum blockchain using Solidity and leverages the OpenZeppelin ERC20 token contract.

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Contracts](#contracts)
- [Setup and Deployment](#setup-and-deployment)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Student Registration**: Students can register with their name and campus email.
- **Charger Management**: Charger owners can add, delist, and manage their chargers.
- **Booking System**: Students can request and confirm bookings for chargers.
- **Peer Ratings**: Students can rate each other based on their experience.
- **Charger Reporting**: Students can report lost or damaged chargers.
- **Token Management**: Students can top-up and cash out tokens using deposited Ether.

## Getting Started

To get started with CMU Charger Hub, follow these steps:

1. Clone the repository to your local machine.
2. Install the required dependencies.
3. Compile the Solidity code using an appropriate compiler.
4. Deploy the compiled contract to the Ethereum network.

## Contracts

The main contract is `StudentChargerSharing`, which extends the OpenZeppelin ERC20 contract. It includes several struct definitions for managing student profiles, chargers, and bookings. The contract uses mappings and events to manage data and track actions on the platform.

## Setup and Deployment

1. Visit the [Remix Ethereum IDE](https://remix.ethereum.org/) in your web browser.
2. Click on the "Solidity" environment in the top-right corner.
3. Create a new file in the "contracts" folder, and copy the contents of the `CMU_charger.sol` contract into the new file.
4. Compile the Solidity code by clicking on the "Solidity Compiler" plugin and selecting the appropriate compiler version.
5. Deploy the compiled contract to the Ethereum network by selecting the "Deploy & Run Transactions" plugin, choosing the desired network and account, and clicking the "Deploy" button.

## Contributing

We welcome contributions from the open-source community. Feel free to star or fork the repository to contribute to the project. If you have any suggestions, improvements, or bug reports, please open an issue or submit a pull request.

## License

CMU Charger Hub is released under the [MIT License](LICENSE). Please refer to the [LICENSE](LICENSE) file for details.

