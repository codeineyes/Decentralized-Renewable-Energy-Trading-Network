;; Energy Trading Contract

(define-non-fungible-token energy-credit uint)

(define-map energy-balances principal uint)
(define-map energy-prices principal uint)

(define-data-var credit-id-nonce uint u0)

(define-public (produce-energy (amount uint))
    (let
        ((new-id (+ (var-get credit-id-nonce) u1))
         (current-balance (default-to u0 (map-get? energy-balances tx-sender))))
        (try! (nft-mint? energy-credit new-id tx-sender))
        (map-set energy-balances tx-sender (+ current-balance amount))
        (var-set credit-id-nonce new-id)
        (ok new-id)
    )
)

(define-public (set-energy-price (price-per-unit uint))
    (begin
        (map-set energy-prices tx-sender price-per-unit)
        (ok true)
    )
)

(define-public (transfer-energy (recipient principal) (amount uint))
    (let
        ((sender-balance (default-to u0 (map-get? energy-balances tx-sender)))
         (recipient-balance (default-to u0 (map-get? energy-balances recipient))))
        (asserts! (>= sender-balance amount) (err u401))
        (map-set energy-balances tx-sender (- sender-balance amount))
        (map-set energy-balances recipient (+ recipient-balance amount))
        (ok true)
    )
)

(define-read-only (get-energy-balance (user principal))
    (ok (default-to u0 (map-get? energy-balances user)))
)

(define-read-only (get-energy-price (user principal))
    (ok (default-to u0 (map-get? energy-prices user)))
)

