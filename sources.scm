
;;; Helpers for parsed sources.
(define (source-protocol l) (car l))
(define (source-url      l) (cadr l))
(define (source-filename l) (caddr l))
(define (source-arrow    l) (cadddr l))

;;; Real stuff.

(define (download-sources cfg recipe sources)
  ""
  (change-directory (alist-ref cfg 'source-dir))
  (if (eq? sources '())
    #t
    (let* ((source   (car sources))
           (arrow    (source-arrow source))
           (protocol (source-protocol source))
           (url      (source-url source))
           (filename (source-filename source)))
      (if (not (file-exists? filename))
        (begin
          (if arrow
            (info "Downloading ~A as ~A." url filename)
            (info "Downloading ~A." url))

          ;; FIXME: MODULEZ
          ;; FIXME: We should try to use an egg or something before defaulting
          ;;        to the shell…
          ;; FIXME: Check the download worked.
          (run* (wget ,url -O ,filename))

          (download-sources cfg recipe (cdr sources)))
      ))))

(define (extract-sources cfg sources)
  ""
  (change-directory (alist-ref cfg 'work-dir))
  (if (eq? sources '())
    #t
    (let* ((source   (car sources))
           (filename (source-filename source)))
      (begin
        ;; FIXME: MODULEZ
        (info "Extracting ~A." filename)
        (run (tar xf ,(string-append
                        (alist-ref configuration 'source-dir)
                        "/"
                        filename)))

        (extract-sources cfg (cdr sources))))))

