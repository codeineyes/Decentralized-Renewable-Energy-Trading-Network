;; Energy Achievements NFT Contract

(define-non-fungible-token energy-achievement uint)

(define-map achievement-types uint
    { name: (string-ascii 50), description: (string-utf8 500), threshold: uint }
)

(define-map user-achievements principal (list 10 uint))

(define-data-var achievement-id-nonce uint u0)

(define-public (create-achievement-type (name (string-ascii 50)) (description (string-utf8 500)) (threshold uint))
    (let
        ((new-id (+ (var-get achievement-id-nonce) u1)))
        (map-set achievement-types new-id
            { name: name, description: description, threshold: threshold }
        )
        (var-set achievement-id-nonce new-id)
        (ok new-id)
    )
)

(define-public (mint-achievement (user principal) (achievement-type-id uint))
    (let
        ((achievement-type (unwrap! (map-get? achievement-types achievement-type-id) (err u404)))
         (user-energy-balance (unwrap! (contract-call? .energy-trading get-energy-balance user) (err u500)))
         (new-id (+ (var-get achievement-id-nonce) u1)))
        (asserts! (>= user-energy-balance (get threshold achievement-type)) (err u401))
        (try! (nft-mint? energy-achievement new-id user))
        (map-set user-achievements user
            (unwrap! (as-max-len?
                (append (default-to (list) (map-get? user-achievements user)) achievement-type-id)
                u10)
                (err u500))
        )
        (var-set achievement-id-nonce new-id)
        (ok new-id)
    )
)

(define-read-only (get-user-achievements (user principal))
    (map-get? user-achievements user)
)

(define-read-only (get-achievement-type (achievement-type-id uint))
    (map-get? achievement-types achievement-type-id)
)

