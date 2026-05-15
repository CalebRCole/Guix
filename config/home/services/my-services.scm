(define-module (services my-services)
  #:use-module (gnu services)
  #:use-module (services bash-service)
  #:use-module (services git-service)
  #:use-module (services guile-service)
  #:use-module (services kanata-service)
  #:use-module (services power-service)
  #:export (my-services))

(define my-services
  (list bash-service
	guile-service
	git-service
	kanata-service
	power-service))
