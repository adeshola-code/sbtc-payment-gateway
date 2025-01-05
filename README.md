# sBTC Payment Gateway Smart Contract

A secure and efficient smart contract system for processing sBTC payments on the Stacks blockchain. This contract enables merchants to accept sBTC payments with automated fee handling, secure withdrawals, and comprehensive payment tracking.

## Features

- 🏪 **Merchant Management**

  - Merchant registration with secure withdrawal addresses
  - Customizable fee structures per merchant
  - Automated payment processing and settlement
  - Real-time balance tracking

- 💸 **Payment Processing**

  - Secure payment creation and processing
  - Automated fee calculations
  - Payment status tracking
  - Optional payment references
  - Minimum payment thresholds

- 🔒 **Security**

  - Role-based access control
  - Contract pause mechanism
  - Secure withdrawal system
  - Comprehensive error handling
  - Input validation

- ⚙️ **Administration**
  - Configurable fee percentages
  - Merchant status management
  - Contract pause/unpause functionality
  - Merchant-specific fee overrides

## Quick Start

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Basic understanding of Clarity and Stacks blockchain

### Installation

1. Clone the repository:

```bash
git clone https://github.com/adeshola-code/sbtc-payment-gateway.git
cd sbtc-payment-gateway
```

2. Run tests:

```bash
clarinet test
```

### Usage Example

```clarity
;; Register as a merchant
(contract-call? .sbtc-payment register-merchant 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Create a payment
(contract-call? .sbtc-payment create-payment
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
    u1000000
    none)

;; Process a payment
(contract-call? .sbtc-payment process-pending-payment u1)
```

## Documentation

For detailed documentation, please refer to the [docs](./docs) directory:

- [Architecture](./docs/ARCHITECTURE.md)
- [API Reference](./docs/API.md)
- [Security](./SECURITY.md)

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## Security

Please review our [Security Policy](SECURITY.md) for reporting security vulnerabilities.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Code of Conduct

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing to this project.
