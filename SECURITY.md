# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of the sBTC Payment Gateway seriously. If you believe you have found a security vulnerability, please report it to us following these steps:

1. **DO NOT** open a public issue
2. Send a detailed description of the vulnerability to adesholasolankerichard@gmail.com
3. Include steps to reproduce the vulnerability
4. If possible, provide a proof of concept

### What to expect

- Acknowledgment of your report within 24 hours
- Regular updates on the progress of addressing the vulnerability
- Credit for responsible disclosure (if desired)

## Security Best Practices

When using this smart contract:

1. Always verify withdrawal addresses carefully
2. Monitor transaction activity regularly
3. Keep private keys secure and never share them
4. Use appropriate fee settings to prevent economic attacks
5. Regularly check contract balances

## Known Security Considerations

1. Fee calculations use integer arithmetic - be aware of rounding
2. Withdrawal addresses must be validated before use
3. Payment references should be properly sanitized
4. Contract owner has significant privileges - use multi-sig when possible

## Security Features

The contract includes several security measures:

- Role-based access control
- Input validation
- Emergency pause functionality
- Secure withdrawal system
- Fee limits and validations
