;; Automated Billing Contract

(define-map billing-cycles
    { user: principal, cycle: uint }
    { start-time: uint, end-time: uint, energy-consumed: uint, amount-due: uint }
)

(define-data-var cycle-nonce uint u0)

(define-public (start-billing-cycle (user principal))
    (let
        ((new-cycle (+ (var-get cycle-nonce) u1)))
        (map-set billing-cycles
            { user: user, cycle: new-cycle }
            { start-time: block-height, end-time: u0, energy-consumed: u0, amount-due: u0 }
        )
        (var-set cycle-nonce new-cycle)
        (ok new-cycle)
    )
)

(define-public (end-billing-cycle (user principal) (cycle uint) (energy-consumed uint))
    (let
        ((cycle-data (unwrap! (map-get? billing-cycles { user: user, cycle: cycle }) (err u404)))
         (energy-price (unwrap! (contract-call? .energy-trading get-energy-price user) (err u500))))
        (map-set billing-cycles
            { user: user, cycle: cycle }
            (merge cycle-data {
                end-time: block-height,
                energy-consumed: energy-consumed,
                amount-due: (* energy-consumed energy-price)
            })
        )
        (ok true)
    )
)

(define-read-only (get-billing-cycle (user principal) (cycle uint))
    (map-get? billing-cycles { user: user, cycle: cycle })
)

