
(define (build-exec funcname configuration recipe)
  ""
  (let ((function (variable-substitute (alist-ref/default recipe funcname #f)
									   `(("PKG" . ,(alist-ref configuration 'destdir))))))
	(if function
		(run ,(string-substitute "\n" ";" function))
		; FIXME: MODULEZ
		)
	))

(define (build configuration recipe)
  ""
  (change-directory (alist-ref configuration 'work-dir))

  ;; Must be done specifically in this order.
  (build-exec 'configure configuration recipe)
  (build-exec 'build     configuration recipe)
  (build-exec 'install   configuration recipe)
  )

