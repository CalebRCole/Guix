(define-module (services gc-service)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (gnu packages package-management)
  #:use-module (gnu services)
  #:use-module (gnu services mcron)
  #:export (gc-service))

(define gc-service
  (simple-service 'hourly-gc-check mcron-service-type
    (list 
     #~(job "0 * * * *" 
            #$(with-imported-modules '((guix build utils)
                                       (ice-9 rdelim))
                #~(begin
                    (use-modules (ice-9 rdelim))
                    (let* ((timestamp-file "/var/lib/guix/last-auto-gc")
                           (now (current-time))
                           (two-weeks (* 14 24 60 60))
                           (last-run (if (file-exists? timestamp-file)
                                         (string->number 
                                          (call-with-input-file timestamp-file read-line))
                                         0)))
                      (when (> (- now last-run) two-weeks)
                        ;; Log the event to the mcron log
                        (display "Threshold reached. Running bi-weekly GC...\n")
                        (if (zero? (system* #$(file-append guix "/bin/guix") "gc" "-d" "14d"))
                            (call-with-output-file timestamp-file
                              (lambda (port) (display now port)))
                            (display "GC failed; timestamp not updated.\n"))))))))))
