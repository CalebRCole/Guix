(define-module (home-config)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (nongnu packages)
  #:use-module (programming-packages)
  #:use-module (web-packages)
  #:use-module (media-packages)
  #:use-module (emulation-packages)
  #:use-module (services my-services))

(home-environment
 (packages (append programming-packages
		   web-packages
	           media-packages
		   emulation-packages))
 (services my-services))
