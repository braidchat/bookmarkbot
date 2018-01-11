#lang braidbot/insta

(require db

         braidbot/util
         braidbot/uuid)

(define bot-id (or (getenv "BOT_ID") "5a565c47-3ab2-4366-bf7b-e98054893043"))
(define bot-token (or (getenv "BOT_TOKEN") "iNtVHA6wIe1_7fioAJ2IBqn_AmJcg6ts2FGDW3VM"))
(define braid-api-url (or (getenv "BRAID_API_URL") "http://localhost:5557"))
(define braid-frontend-url (or (getenv "BRAID_FRONTEND_URL") "http://localhost:5555"))

(listen-port 9191)

(on-init (λ () (println "Bot starting")))

;;; Helper functions

(define (thread-link msg)
  (string-join
   (list braid-frontend-url
         "/groups/"
         (uuid->string (hash-ref msg '#:group-id))
         "/thread/"
         (uuid->string (hash-ref msg '#:thread-id)))
   ""))

(define (new-message)
  (make-immutable-hasheq
   (list (cons '#:id (make-uuid))
         (cons '#:content "")
         (cons '#:thread-id (make-uuid))
         (cons '#:mentioned-user-ids '())
         (cons '#:mentioned-tag-ids '()))))

;;; Saving & retrieving bookmarks

(define user->saved (make-hash))

(define (save-bookmark user-id to-save)
  (~>> (hash-ref! user->saved user-id '())
       (cons to-save)
       (hash-set! user->saved user-id)))

(define (bookmarks-for user-id)
  (hash-ref! user->saved user-id '()))


;;; Parsing messages

(define msg-handlers
  (list
   (cons #rx"^/bookmark add (.*)$"
         (λ (msg matches)
           (~>> (if (string=? (car matches) "this")
                   (thread-link msg)
                   (car matches))
               (save-bookmark (hash-ref msg '#:user-id)))))

   (cons #rx"^/bookmark list$"
         (λ (msg _)
           (let* ([user-id (hash-ref msg '#:user-id)]
                  [saved (bookmarks-for user-id)])
             (~> (new-message)
                 (hash-set '#:mentioned-user-ids (list user-id))
                 (hash-set '#:content (string-join saved "\n"))
                 (send-message
                  #:bot-id bot-id
                  #:bot-token bot-token
                  #:braid-url braid-api-url)))))))

(define (handle-message msg)
  (let ([content (hash-ref msg '#:content)])
    (for/first ([re-fn msg-handlers]
                #:when (regexp-match (car re-fn) content))
      ((cdr re-fn) msg (cdr (regexp-match (car re-fn) content))))))

;;; Main

(define (act-on-message msg)
  (println msg)
  (handle-message msg))
