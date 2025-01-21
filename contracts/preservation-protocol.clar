;; Preservation Protocol Contract

(define-data-var protocol-counter uint u0)

(define-map preservation-protocols uint {
  relic-id: uint,
  curator: principal,
  protocol-name: (string-ascii 50),
  protocol-description: (string-utf8 500),
  start-date: uint,
  last-update: uint,
  status: (string-ascii 20)
})

(define-public (create-protocol (relic-id uint) (name (string-ascii 50)) (description (string-utf8 500)))
  (let
    ((new-id (+ (var-get protocol-counter) u1)))
    (map-set preservation-protocols new-id {
      relic-id: relic-id,
      curator: tx-sender,
      protocol-name: name,
      protocol-description: description,
      start-date: block-height,
      last-update: block-height,
      status: "active"
    })
    (var-set protocol-counter new-id)
    (ok new-id)
  )
)

(define-public (update-protocol (protocol-id uint) (description (string-utf8 500)))
  (let
    ((protocol (unwrap! (map-get? preservation-protocols protocol-id) (err u404))))
    (asserts! (is-eq tx-sender (get curator protocol)) (err u403))
    (ok (map-set preservation-protocols protocol-id
      (merge protocol {
        protocol-description: description,
        last-update: block-height
      })))
  )
)

(define-public (change-protocol-status (protocol-id uint) (new-status (string-ascii 20)))
  (let
    ((protocol (unwrap! (map-get? preservation-protocols protocol-id) (err u404))))
    (asserts! (is-eq tx-sender (get curator protocol)) (err u403))
    (ok (map-set preservation-protocols protocol-id
      (merge protocol { status: new-status })))
  )
)

(define-read-only (get-preservation-protocol (protocol-id uint))
  (map-get? preservation-protocols protocol-id)
)

(define-read-only (get-protocol-count)
  (var-get protocol-counter)
)

