(define-module (services bash-service)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (guix gexp)
  #:export (bash-service))

(define bash-service
  (service home-bash-service-type
           (home-bash-configuration
  	    (aliases '(("ls" . "ls --color=auto")
  		       ("grep" . "grep --color=auto")
  		       ("ip" . "ip --color=auto")
  		       ("s" . "sudo")
  		       ("gsr" . "sudo guix system reconfigure")
  		       ("ghr" . "guix home reconfigure")))
	    (bashrc (list (plain-file "bashrc"
				"
export GUIX_PROFILE=\"$HOME/.guix-profile\"
if [ -f \"$GUIX_PROFILE/etc/profile\" ]; then
  . \"$GUIX_PROFILE/etc/profile\"
fi")))
  	    (bash-profile (list (plain-file "bash_profile"
				      "
GUIX_PROFILE=\"$HOME/.guix-profile\"
. \"$GUIX_PROFILE/etc/profile\"

if [[ ! -S ${XDG_RUNTIME_DIR-$HOME/.cache}/shepherd/socket ]]; then
    shepherd
fi")))
      	    (guix-defaults? #t))))
