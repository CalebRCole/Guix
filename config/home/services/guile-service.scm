(define-module (services guile-service)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (guix gexp)
  #:export (guile-service))

(define guile-service
  (simple-service 'my-guile-configuration home-files-service-type
		  `(("guile/.guile"
		     ,(plain-file "guile"
				  "(use-modules (ice-9 readline) (ice-9 colorized))

(activate-readline)
(activate-colorized)")))))
