;; Cosmic Relic Marketplace Contract

(define-map listings uint {
  seller: principal,
  token-type: (string-ascii 30),
  token-id: uint,
  price: uint
})

(define-data-var listing-counter uint u0)

(define-constant ERR-NOT-OWNER (err u100))
(define-constant ERR-LISTING-NOT-FOUND (err u101))
(define-constant ERR-INSUFFICIENT-FUNDS (err u102))

(define-public (create-listing (token-type (string-ascii 30)) (token-id uint) (price uint))
  (let
    ((listing-id (+ (var-get listing-counter) u1)))
    (asserts! (or
      (and (is-eq token-type "cosmic-relic") (is-eq tx-sender (unwrap! (nft-get-owner? cosmic-relic token-id) ERR-NOT-OWNER)))
      (and (is-eq token-type "preservation-technique") (is-eq tx-sender (unwrap! (nft-get-owner? preservation-technique token-id) ERR-NOT-OWNER)))
    ) ERR-NOT-OWNER)
    (map-set listings listing-id {
      seller: tx-sender,
      token-type: token-type,
      token-id: token-id,
      price: price
    })
    (var-set listing-counter listing-id)
    (ok listing-id)
  )
)

(define-public (purchase-listing (listing-id uint))
  (let
    ((listing (unwrap! (map-get? listings listing-id) ERR-LISTING-NOT-FOUND))
     (buyer tx-sender))
    (try! (stx-transfer? (get price listing) buyer (get seller listing)))
    (if (is-eq (get token-type listing) "cosmic-relic")
      (try! (nft-transfer? cosmic-relic (get token-id listing) (get seller listing) buyer))
      (try! (nft-transfer? preservation-technique (get token-id listing) (get seller listing) buyer))
    )
    (map-delete listings listing-id)
    (ok true)
  )
)

(define-read-only (get-listing (listing-id uint))
  (map-get? listings listing-id)
)

(define-read-only (get-listing-count)
  (var-get listing-counter)
)

