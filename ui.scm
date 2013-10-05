
(use format)

;; FIXME: VT100-dependent
(define colors-red    "\033[01;31m")
(define colors-green  "\033[01;32m")
(define colors-yellow "\033[01;33m")
(define colors-white  "\033[01;37m")
(define colors-reset  "\033[00m")

(define (info str . args)
  (printf colors-green)
  (printf "-- ")
  (printf colors-white)
  (write-string (apply format str args))
  (printf colors-reset)
  (printf "~%"))

(define (warning str . args)
  (with-output-to-port (current-error-port)
    (begin
      (printf colors-yellow)
      (printf "-- ")
      (write-string (apply format str args))
      (printf colors-reset)
      (printf "~%")
	  (lambda () '()) ; FIXME: WTF
      )))

(define (die r str . args)
  (with-output-to-port (current-error-port)
    (begin
      (printf colors-red)
      (printf "-- ")
      (write-string (apply format str args))
      (printf colors-reset)
      (printf "~%")
	  (exit r)
      )))

