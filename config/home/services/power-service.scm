(define-module (services power-service)
  #:use-module (gnu services)
  #:use-module (gnu home services pm)
  #:export (power-service))

(define power-service
  (service home-batsignal-service-type
	   (home-batsignal-configuration
	    (warning-level 20)
	    (critical-level 10)
	    (danger-level 5))))
