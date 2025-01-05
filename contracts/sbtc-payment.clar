
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