(define-module (services kanata-service)
  #:use-module (gnu services)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages rust-apps)
  #:use-module (guix gexp)
  #:export (kanata-service))

(define kanata-service
  (simple-service 'kanata-service home-shepherd-service-type
		  (list (let ((config "../../files/kanata/config.kbd"))
			  (shepherd-service
			   (documentation "Kanata keyboard remapper")
			   (provision '(kanata))
			   (start #~(make-forkexec-constructor
				     (list #$(file-append kanata "/bin/kanata")
					   "--cfg" #$(local-file config))
				     #:log-file (string-append (or (getenv "XDG_STATE_HOME")
								   (string-append (getenv "HOME") "/.local/state"))
							       "/log/kanata.log")))
			   (stop #~(make-kill-destructor))
			   (respawn? #t))))))
