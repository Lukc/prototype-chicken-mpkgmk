
(use extras utils posix alist-lib regex shell)

(define pwd (current-directory))

(define configuration `(
  (work-dir   . ,(string-append pwd "/work"))
  (destdir    . ,(string-append pwd "/pkg"))
  (source-dir . ,pwd)
  ;; FIXME: LOTS of things are missing from this list.
  (prefixes . (("prefix" . "/usr")
               ("mandir" . "/usr/man")
               ("libdir" . "/usr/lib")
               ("bindir" . "/usr/bin")
               ))
))

(include "ui.scm")
(include "recipe.scm")
(include "sources.scm")
(include "build.scm")
(include "assemble.scm")

;; Recipe-parsing.
(if (regular-file? "package.yaml")
  (define recipe (load-recipe configuration "package.yaml"))
  (die 1 "No package.yaml in current directory."))

;; Creating work dirs.
(map (lambda (dir)
       (let ((dir (alist-ref configuration dir)))
         (if (not (directory? dir))
           (create-directory dir))))
     '(work-dir destdir source-dir))

;; And so it begins.

(download-sources configuration recipe (alist-ref recipe 'source))
(extract-sources configuration (alist-ref recipe 'source))

(build configuration recipe)
(assemble configuration recipe)

