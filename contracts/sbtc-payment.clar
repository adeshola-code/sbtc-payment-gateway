
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