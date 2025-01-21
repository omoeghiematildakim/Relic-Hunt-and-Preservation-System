;; Authentication Process Contract

(define-data-var process-counter uint u0)

(define-map authentication-processes uint {
  discovery-id: uint,
  authenticator: principal,
  start-date: uint,
  end-date: uint,
  status: (string-ascii 20),
  verification-method: (string-ascii 100)
})

(define-public (start-authentication (discovery-id uint) (verification-method (string-ascii 100)))
  (let
    ((new-id (+ (var-get process-counter) u1)))
    (map-set authentication-processes new-id {
      discovery-id: discovery-id,
      authenticator: tx-sender,
      start-date: block-height,
      end-date: u0,
      status: "in-progress",
      verification-method: verification-method
    })
    (var-set process-counter new-id)
    (ok new-id)
  )
)

(define-public (complete-authentication (process-id uint) (result (string-ascii 20)))
  (let
    ((process (unwrap! (map-get? authentication-processes process-id) (err u404))))
    (asserts! (is-eq tx-sender (get authenticator process)) (err u403))
    (ok (map-set authentication-processes process-id
      (merge process {
        end-date: block-height,
        status: result
      })))
  )
)

(define-read-only (get-authentication-process (process-id uint))
  (map-get? authentication-processes process-id)
)

(define-read-only (get-process-count)
  (var-get process-counter)
)

