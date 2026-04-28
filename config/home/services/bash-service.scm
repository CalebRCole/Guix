(define-module (services bash-service)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:export (bash-service))

(define bash-service
  (service home-bash-service-type
      	   (home-bash-configuration
	    (aliases '(("ls" . "ls --color=")
		       ("grep" . "grep --color=auto")
		       ("ip" . "ip --color=auto")
		       ("s" . "sudo")
		       ("gsr" . "guix system reconfigure")
		       ("ghr" . "guix home reconfigure")))
    	    (guix-defaults? #t))))
