#lang info
(define collection "bookmarkbot")
(define deps '("base"
               "https://github.com/braidchat/braidbot.git#v2.0"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/bookmarkbot.scrbl" ())))
(define pkg-desc "Description Here")
(define version "0.0")
(define pkg-authors '(james))
