# API Reference

## Public Functions

### Merchant Management

#### `register-merchant`

```clarity
(define-public (register-merchant (withdrawal-address principal)) response)
```

Registers a new merchant in the system.

Parameters:

- `withdrawal-address`: Principal address for receiving payments

Returns:

- `(ok true)` on success
- Error codes on failure

#### `withdraw-balance`

```clarity
(define-public (withdraw-balance (amount uint)) response)
```

Withdraws available balance to the merchant's withdrawal address.

Parameters:

- `amount`: Amount to withdraw in micro-sBTC

Returns:

- `(ok true)` on success
- Error codes on failure

### Payment Operations

#### `create-payment`

```clarity
(define-public (create-payment
    (merchant principal)
    (amount uint)
    (reference (optional (string-ascii 64)))
) response)
```

Creates a new payment for processing.

Parameters:

- `merchant`: Merchant's principal address
- `amount`: Payment amount in micro-sBTC
- `reference`: Optional payment reference

Returns:

- `(ok uint)` with payment ID on success
- Error codes on failure

#### `process-pending-payment`

```clarity
(define-public (process-pending-payment (payment-id uint)) response)
```

Processes a pending payment.

Parameters:

- `payment-id`: ID of the payment to process

Returns:

- `(ok true)` on success
- Error codes on failure

### Admin Functions

#### `set-fee-percentage`

```clarity
(define-public (set-fee-percentage (new-fee uint)) response)
```

Sets the global fee percentage (in basis points).

Parameters:

- `new-fee`: New fee percentage (100 = 1%)

Returns:

- `(ok true)` on success
- Error codes on failure

#### `set-merchant-fee-override`

```clarity
(define-public (set-merchant-fee-override
    (merchant principal)
    (fee (optional uint))
) response)
```

Sets a custom fee override for a specific merchant.

Parameters:

- `merchant`: Merchant's principal address
- `fee`: Optional custom fee percentage

Returns:

- `(ok true)` on success
- Error codes on failure

## Read-Only Functions

### `get-payment`

```clarity
(define-read-only (get-payment (payment-id uint))
    (optional {
        merchant: principal,
        amount: uint,
        customer: principal,
        status: (string-ascii 20),
        created-at: uint,
        processed-at: (optional uint),
        reference: (optional (string-ascii 64))
    })
)
```

Retrieves payment information.

### `get-merchant-info`

```clarity
(define-read-only (get-merchant-info (merchant principal))
    (optional {
        active: bool,
        total-volume: uint,
        payment-count: uint,
        withdrawal-address: (optional principal),
        fee-override: (optional uint)
    })
)
```

Retrieves merchant information.

### `get-merchant-balance`

```clarity
(define-read-only (get-merchant-balance (merchant principal)) uint)
```

Retrieves current merchant balance.

### `get-contract-info`

```clarity
(define-read-only (get-contract-info)
    {
        owner: principal,
        paused: bool,
        fee-percentage: uint,
        min-payment: uint,
        total-payments: uint
    }
)
```

Retrieves contract configuration and status.

## Error Codes

| Code | Description                |
| ---- | -------------------------- |
| u100 | Not authorized             |
| u101 | Invalid amount             |
| u102 | Payment not found          |
| u103 | Invalid merchant           |
| u104 | Payment already processed  |
| u105 | Insufficient balance       |
| u106 | Invalid status             |
| u107 | Invalid fee                |
| u108 | Invalid withdrawal address |
