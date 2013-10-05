
(define assemblers '())

(alist-set! assemblers 'crux
  `(
    (assemble . ,(lambda (configuration recipe)
                   (let* ((package-name (string-append
                                          (alist-ref recipe 'name)
                                          "#"
                                          (alist-ref recipe 'version)
                                          "-"
                                          (number->string
                                            (alist-ref recipe 'release))
                                          ".tar.xz"))
                          (filename (string-append
                                      (alist-ref configuration 'source-dir)
                                      "/"
                                      package-name)))
                     (begin
                       (run (tar cJf
                                 ,filename
                                 "."))
                       (info "~A assembled." package-name)))))
    )
  )

(define (assemble configuration recipe)
  ""
  (change-directory (alist-ref configuration 'destdir))

  ;(assembler configuration recipe)
  ;; FIXME: MODULEZ
  ((alist-ref (alist-ref assemblers 'crux) 'assemble)
   configuration recipe)
  )

