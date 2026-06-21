(define-module (services btrfs-service)
  #:use-module (guix gexp)
  #:use-module (gnu services)
  #:use-module (gnu services mcron)
  #:use-module (base-system)
  #:export (btrfs-service))

(define btrfs-service
  (list (simple-service 'persistant-symlinks activation-service-type
			#~(begin
			    (use-modules (guix build utils))
			    (let ((files '("/etc/machine-id")))
			      (for-each
			       (lambda (file)
				 (let ((persist-file (string-append "/persist" file)))
				   (mkdir-p (dirname persist-file))
				   (mkdir-p (dirname file))
				   (unless (file-exists? persist-file)
				     (call-with-output-file persist-file (lambda (p) (display "" p))))
				   (when (file-exists? file) (delete-file file))
				   (symlink persist-file file)))
			       files))))

	(simple-service 'snapper-config etc-service-type
			`(("snapper/configs/config" ,(plain-file "config"
								 (string-append
								  "SUBVOLUME=\"/mnt/persist\"\n"
								  "FSTYPE=\"btrfs\"\n"
								  (string-append "ALLOW_USERS=\"" %my-user "\"\n")
								  "ALLOW_GROUPS=\"users\"\n"
								  "SYNC_ACL=\"yes\"\n"
								  "TIMELINE_CLEANUP=\"yes\"\n"
								  "TIMELINE_MIN_AGE=\"1800\"\n"
								  "TIMELINE_LIMIT_HOURLY=\"12\"\n"
								  "TIMELINE_LIMIT_DAILY=\"7\"\n"
								  "TIMELINE_LIMIT_WEEKLY=\"4\"\n"
								  "TIMELINE_LIMIT_MONTHLY=\"3\"\n"
								  "TIMELINE_LIMIT_YEARLY=\"1\"\n")))
			  ("default/snapper" ,(plain-file "snapper-default" "SNAPPER_CONFIGS=\"config\""))))
	(simple-service 'snapper-jobs mcron-service-type
			(list
			 #~(job '(next-hour)
				"snapper -c config create --cleanup-algorithm timeline --description 'Hourly'")
			 #~(job '(next-hour '(5))
				"snapper -c config cleanup timeline")))))
