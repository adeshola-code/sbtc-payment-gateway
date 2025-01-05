
;; Title: sBTC Payment Gateway Smart Contract

;; Summary:
;; A secure and efficient payment processing system for merchants to accept sBTC payments.
;; Handles payment creation, processing, merchant management, and automated fee calculations.

;; ==============================================
;; Constants and Configuration
;; ==============================================

;; Contract Owner
(define-constant CONTRACT_OWNER tx-sender)

;; Error Codes
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_PAYMENT_NOT_FOUND (err u102))
(define-constant ERR_INVALID_MERCHANT (err u103))
(define-constant ERR_PAYMENT_ALREADY_PROCESSED (err u104))
(define-constant ERR_INSUFFICIENT_BALANCE (err u105))
(define-constant ERR_INVALID_STATUS (err u106))

;; ==============================================
;; Data Variables
;; ==============================================

;; Contract State
(define-data-var contract-paused bool false)

;; Fee Configuration
(define-data-var fee-percentage uint u100) ;; 1% = 100 basis points
(define-data-var min-payment uint u1000000) ;; 0.01 sBTC in micro-sBTC

;; Payment Counter
(define-data-var payment-nonce uint u0)

;; ==============================================
;; Data Maps
;; ==============================================

;; Merchant Registry
(define-map merchants
    principal
    {
        active: bool,
        total-volume: uint,
        payment-count: uint,
        withdrawal-address: (optional principal),
        fee-override: (optional uint)
    }
)

;; Payment Records
(define-map payments
    uint
    {
        merchant: principal,
        amount: uint,
        customer: principal,
        status: (string-ascii 20),
        created-at: uint,
        processed-at: (optional uint),
        reference: (optional (string-ascii 64))
    }
)

;; Merchant Balances
(define-map merchant-balances principal uint)

;; ==============================================
;; Private Functions
;; ==============================================

;; Authorization Checks
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT_OWNER)
)

(define-private (is-merchant (merchant principal))
    (default-to 
        false
        (get active (map-get? merchants merchant))
    )
)

;; Fee Calculations
(define-private (calculate-fee (amount uint) (merchant principal))
    (let (
        (merchant-data (unwrap! (map-get? merchants merchant) ERR_INVALID_MERCHANT))
        (fee-rate (default-to (var-get fee-percentage) (get fee-override merchant-data)))
    )
    (/ (* amount fee-rate) u10000))
)

;; Payment Processing Logic
(define-private (process-payment (payment-id uint) (payment-data {merchant: principal, amount: uint, customer: principal, status: (string-ascii 20), created-at: uint, processed-at: (optional uint), reference: (optional (string-ascii 64))}))
    (let (
        (fee (calculate-fee (get amount payment-data) (get merchant payment-data)))
        (net-amount (- (get amount payment-data) fee))
    )
    (begin
        ;; Update merchant balance
        (map-set merchant-balances 
            (get merchant payment-data)
            (+ (default-to u0 (map-get? merchant-balances (get merchant payment-data))) net-amount)
        )
        ;; Update merchant stats
        (map-set merchants
            (get merchant payment-data)
            (merge
                (unwrap! (map-get? merchants (get merchant payment-data)) ERR_INVALID_MERCHANT)
                {
                    total-volume: (+ (get amount payment-data) (get total-volume (unwrap! (map-get? merchants (get merchant payment-data)) ERR_INVALID_MERCHANT))),
                    payment-count: (+ u1 (get payment-count (unwrap! (map-get? merchants (get merchant payment-data)) ERR_INVALID_MERCHANT)))
                }
            )
        )
        ;; Update payment status
        (map-set payments
            payment-id
            (merge payment-data {
                status: "completed",
                processed-at: (some block-height)
            })
        )
        (ok true)
    ))
)

;; ==============================================
;; Public Functions - Merchant Management
;; ==============================================

(define-public (register-merchant (withdrawal-address principal))
    (begin
        (asserts! (not (is-merchant tx-sender)) ERR_NOT_AUTHORIZED)
        (map-set merchants
            tx-sender
            {
                active: true,
                total-volume: u0,
                payment-count: u0,
                withdrawal-address: (some withdrawal-address),
                fee-override: none
            }
        )
        (ok true)
    )
)

(define-public (withdraw-balance (amount uint))
    (let (
        (merchant-data (unwrap! (map-get? merchants tx-sender) ERR_INVALID_MERCHANT))
        (current-balance (default-to u0 (map-get? merchant-balances tx-sender)))
        (withdrawal-addr (unwrap! (get withdrawal-address merchant-data) ERR_NOT_AUTHORIZED))
    )
    (begin
        (asserts! (>= current-balance amount) ERR_INSUFFICIENT_BALANCE)
        (try! (stx-transfer? amount tx-sender withdrawal-addr))
        (map-set merchant-balances
            tx-sender
            (- current-balance amount)
        )
        (ok true)
    ))
)

;; ==============================================
;; Public Functions - Payment Operations
;; ==============================================

(define-public (create-payment (merchant principal) (amount uint) (reference (optional (string-ascii 64))))
    (begin
        (asserts! (>= amount (var-get min-payment)) ERR_INVALID_AMOUNT)
        (asserts! (is-merchant merchant) ERR_INVALID_MERCHANT)
        (let (
            (payment-id (+ (var-get payment-nonce) u1))
        )
        (begin
            (var-set payment-nonce payment-id)
            (map-set payments
                payment-id
                {
                    merchant: merchant,
                    amount: amount,
                    customer: tx-sender,
                    status: "pending",
                    created-at: block-height,
                    processed-at: none,
                    reference: reference
                }
            )
            (ok payment-id)
        ))
    )
)

(define-public (process-pending-payment (payment-id uint))
    (let (
        (payment (unwrap! (map-get? payments payment-id) ERR_PAYMENT_NOT_FOUND))
    )
    (begin
        (asserts! (is-eq (get status payment) "pending") ERR_INVALID_STATUS)
        (asserts! (is-eq tx-sender (get customer payment)) ERR_NOT_AUTHORIZED)
        (try! (stx-transfer? (get amount payment) tx-sender (get merchant payment)))
        (process-payment payment-id payment)
    ))
)