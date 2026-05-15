(define-module (language-packages)
  #:use-module (guix)
  #:use-module (gnu packages)
  #:use-module (gnu packages guile)
  #:export (language-packages))

(define language-packages
  (specifications->packages (list "guile"
				 "guile-readline"
				 "guile-colorized")))
