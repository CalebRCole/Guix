(define-module (emulation-packages)
  #:use-module (gnu packages)
  #:export (emulation-packages))

(define emulation-packages
  (specifications->packages (list "kanata"
				  "qemu")))
