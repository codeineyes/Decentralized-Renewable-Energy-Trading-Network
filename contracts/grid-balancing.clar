;; Grid Balancing Contract

(define-map grid-status uint
    { total-supply: uint, total-demand: uint, balance: int }
)

(define-data-var current-interval uint u0)

(define-public (update-grid-status (supply uint) (demand uint))
    (let
        ((interval (var-get current-interval))
         (balance (- supply demand)))
        (map-set grid-status interval
            { total-supply: supply, total-demand: demand, balance: balance }
        )
        (var-set current-interval (+ interval u1))
        (ok interval)
    )
)

(define-public (request-energy (amount uint))
    (let
        ((interval (var-get current-interval))
         (status (unwrap! (map-get? grid-status interval) (err u404))))
        (asserts! (>= (get balance status) (to-int amount)) (err u401))
        (map-set grid-status interval
            (merge status {
                total-demand: (+ (get total-demand status) amount),
                balance: (- (get balance status) (to-int amount))
            })
        )
        (ok true)
    )
)

(define-read-only (get-grid-status (interval uint))
    (map-get? grid-status interval)
)

