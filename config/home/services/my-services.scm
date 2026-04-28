(define-module (services my-services)
  #:use-module (services bash-service)
  #:use-module (services git-service)
  #:use-module (services power-service)
  #:export (my-services))

(define my-services
  (list bash-service
	git-service
	power-service))
