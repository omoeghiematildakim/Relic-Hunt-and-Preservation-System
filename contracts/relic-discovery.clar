;; Relic Discovery Contract

(define-data-var discovery-counter uint u0)

(define-map relic-discoveries uint {
  discoverer: principal,
  coordinates: (string-ascii 50),
  relic-type: (string-ascii 50),
  discovery-date: uint,
  authentication-status: (string-ascii 20)
})

(define-public (register-discovery (coordinates (string-ascii 50)) (relic-type (string-ascii 50)))
  (let
    ((new-id (+ (var-get discovery-counter) u1)))
    (map-set relic-discoveries new-id {
      discoverer: tx-sender,
      coordinates: coordinates,
      relic-type: relic-type,
      discovery-date: block-height,
      authentication-status: "pending"
    })
    (var-set discovery-counter new-id)
    (ok new-id)
  )
)

(define-public (update-authentication-status (discovery-id uint) (new-status (string-ascii 20)))
  (let
    ((discovery (unwrap! (map-get? relic-discoveries discovery-id) (err u404))))
    (asserts! (is-eq tx-sender (get discoverer discovery)) (err u403))
    (ok (map-set relic-discoveries discovery-id
      (merge discovery { authentication-status: new-status })))
  )
)

(define-read-only (get-discovery (discovery-id uint))
  (map-get? relic-discoveries discovery-id)
)

(define-read-only (get-discovery-count)
  (var-get discovery-counter)
)

