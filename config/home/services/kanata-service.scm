(define-module (services kanata-service)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages rust-apps)
  #:use-module (guix gexp)
  #:export (kanata-service))

(define kanata-config-file
  (local-file "../../../files/kanata/config.kbd"))

(define kanata-service
  (list (service home-shepherd-service-type
           (list (shepherd-service
                  (provision '(kanata))
                  (documentation "Kanata keyboard remapper.")
                  (start #~(make-forkexec-constructor
                            (list #$(file-append kanata "/bin/kanata")
                                  "--cfg" #$kanata-config-file)
                            #:log-file (string-append (getenv "HOME") "/.local/state/log/kanata.log")))
                  (stop #~(make-kill-destructor)))))
