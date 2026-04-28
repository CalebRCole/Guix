(define-module (web-packages)
  #:use-module (gnu packages)
  #:export (web-packages))

(define web-packages
  (specifications->packages
   (list "torbrowser"
	 "librewolf")))
