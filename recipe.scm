
(use yaml utils extras)

;;; Shell-like variables replacement.

(define (variable-substitute string list)
  ""
  (string-substitute* string
                      (map (lambda (elem) (cons
                            (string-append "\\$" (car elem) "([^a-zA-Z_])")
                            (string-append (cdr elem) "\\1")))
                           list)))

;;; Sources.

(define (get-source-protocol string)
  (if (string-match ".*:.*" string)
    (string-substitute* string
                        '((":.*" . "")
                          ("\\+.*" . "")))
    "file")) ; default

(define (parse-sources sources name version)
  (map (lambda (elem)
         (if (string-match ".* -> .*" elem)
           (list (get-source-protocol elem)
                 (string-substitute " -> .*" "" elem)
                 (string-substitute ".* -> " "" elem)
                 #t)
           (list (get-source-protocol elem)
                 elem
                 (string-substitute ".*/" "" elem)
                 #f)))
       (map (lambda (string)
              (variable-substitute string
                                   `(("version" . ,version)
                                     ("name"    . ,name))))
              sources)))

;;; And so it begins.

(define (load-recipe configuration file)
  ""
  (define recipe (map (lambda (elem) (cons (string->symbol (car elem))
                                           (cdr elem)))
                      (yaml-load (read-all file))))

  (map (lambda (key)
         (if (not (alist-ref/default recipe key #f))
           (die 2 "Vital variable missing: ~A." key)))
       '(name version source))

  ;; Note: The alist-set!s don’t replace the old value, they just add a new
  ;;       one with the same key.
  ;; FIXME: Replace the alist-set!s by a *really* destructive method.

  ;; Default release.
  (if (not (alist-ref/default recipe 'release #f))
    (alist-set! recipe 'release 1))

  ;; Non-string version.
  (define version (alist-ref recipe 'version))
  (if (number? version)
    (alist-set! recipe 'version (number->string version)))

  ;; Management of the sources.
  (if (string? (alist-ref recipe 'source))
    (alist-set! recipe 'source (list (alist-ref recipe 'source))))
  (alist-set! recipe 'source (parse-sources
                                (alist-ref recipe 'source)
                                (alist-ref recipe 'name)
                                (alist-ref recipe 'version)))

  ;; Build functions.
  (define dirname (if (alist-ref/default recipe 'dirname #f)
                    (alist-ref recipe 'dirname)
                    (string-append (alist-ref recipe 'name)
                                   "-"
                                   (alist-ref recipe 'version))))
  (map (lambda (funcname)
    (if (alist-ref/default recipe funcname #f)
      (alist-set! recipe funcname
                  (variable-substitute
                    (variable-substitute
                      (alist-ref recipe funcname)
                                        `(("dirname" . ,dirname)
                                          ("version" . ,(alist-ref
                                                          recipe
                                                          'version))))
                    (alist-ref/default configuration 'prefixes '())))))
    '(configure build install))

  ;; FIXME: Splits, useflags (diffs), distro-dependent stuff (diffs)

  recipe)

