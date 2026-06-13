(define-module (taurinus-alpha)
  #:use-module (guix)
  #:use-module (guix gexp)
  #:use-module (guix build utils)
  #:use-module (guix transformations)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu services pm)
  #:use-module (gnu services authentication)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages file-systems)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module ((nongnu packages linux) #:prefix nongnu:)
  #:use-module (nongnu system linux-initrd)
  #:use-module (services btrfs-service)
  #:use-module (base-system)
  #:export (taurinus-alpha-record))

;; Helper function to make adding bind-mounts simple.
(define (persistent-subvolume path dependencies)
  (let ((persist-path (string-append "/persist/" path)))
    (mkdir-p persist-path)		; Ensures the paths are present, and generates them if they are not.
    (file-system
     (device persist-path)
     (mount-point (string-append "/" path))
     (type "none")
     (flags '(bind-mount))
     (create-mount-point? #t)
     (needed-for-boot? #t)
     (dependencies dependencies))))

(define %btrfs-rollback-hook
  #~(lambda (mount-args)
      (let ((target "/mnt-parent"))
	(mkdir target)
	;; Mount the top-level Btrfs filesystem (subvol ID 5) to /mnt-parent
	(if (zero? (system* "mount" "-o" "subvol=/" "/dev/mapper/Guix" target))
            (begin
              (display "Wiping ephemeral root file system...\n")
              ;; Delete the mutated @root subvolume
              (system* "btrfs" "subvolume" "delete" 
                       (string-append target "/@root"))
              ;; Recreate @root from the pristine @root_blank template
              (system* "btrfs" "subvolume" "snapshot" 
                       (string-append target "/@root_blank") 
                       (string-append target "/@root"))
              ;; Unmount and cleanup
              (system* "umount" target)
              (rmdir target)
              (display "Rollback complete!\n"))
            (display "WARNING: Failed to mount Btrfs root for rollback!\n")))))

;; Exported for use in generating an image for system installation.
(define taurinus-alpha-record
  (operating-system
   (inherit base-system)
   (host-name "taurinus-alpha")

   ;; Ramdisk setup. Uses hook to wipe root for ephemeral root.
   (initrd (lambda (file-systems . rest)
             (let ((base (apply base-initrd file-systems
                                #:extra-modules '("btrfs") ; Load Btrfs drivers early
                                rest)))
               (expression->initrd
                #~(begin
                    (#$%btrfs-rollback-hook #f)
                    (load #$base))
                #:name "guix-rollback-initrd"))))
   

   (mapped-devices (list (mapped-device
			  (source (uuid "72859a88-811b-456e-98d6-40e34fc39ed0"))
			  (target "Guix")
			  (type luks-device-mapping))))

   (file-systems
    (append (list
  	     ;; Boot partition.
  	     (file-system
  	      (mount-point "/boot/efi")
  	      (device (file-system-label "BOOT"))
  	      (type "vfat")
	      (needed-for-boot? #t)
	      (flags '(no-exec))
	      (options "umask=0077"))

	     ;; Root volume. Gets overwritten by blank root sub-volume.
	     (file-system
	      (mount-point "/")
	      (device (uuid "ac384527-0f36-4850-ba65-657fef2d18fe"))
	      (type "btrfs")
	      (needed-for-boot? #t)
	      (flags '(no-dev no-atime no-suid))
	      (options "subvol=@root,compress=zstd,space_cache=v2")
	      (dependencies mapped-devices))

  	     ;; Mounting for the store.
  	     (file-system
  	      (mount-point "/gnu")
  	      (device (uuid "ac384527-0f36-4850-ba65-657fef2d18fe"))
  	      (type "btrfs")
  	      (needed-for-boot? #t)
  	      (flags '(no-atime))
  	      (options "subvol=@gnu,compress=zstd,space_cache=v2")
  	      (dependencies mapped-devices))

	     ;; Persistence sub-volume.
	     (file-system
	      (mount-point "/persist")
	      (device (uuid "ac384527-0f36-4850-ba65-657fef2d18fe"))
	      (type "btrfs")
	      (needed-for-boot? #t)
	      (flags '(no-atime no-suid))
	      (options "subvol=@persist,compress=zstd,space_cache=v2")
	      (dependencies mapped-devices)))

	    ;; Bind-mounts.
	    (map (lambda (paths)
		   (persistent-subvolume paths mapped-devices))
		 (list "etc/guix"	   ; Guix Daemon
		       "var/guix"	   ; Guix Core
		       "var/lib"	   ; Libraries
		       "var/log"	   ; Logs
		       "etc/NetworkManager/system-connections" ; NetworkManager Connections
		       "etc/ssh"	     ; SSH Host Keys
		       "etc/cups"	     ; CUPS Printing
		       "etc/snapper/configs" ; Snapper Configurations
		       "etc/default/snapper"
		       ))
	    %base-file-systems))

   (swap-devices
    (list (swap-space
	   (target (file-system-label "swap")))))
   
   (services
    (append (list (service tlp-service-type
  			   (tlp-configuration
  			    (cpu-boost-on-ac? #t)
  			    (wifi-pwr-on-bat? #t)))
		  (service fprintd-service-type))
	    btrfs-service
	    (operating-system-user-services base-system)))

   (packages
    (append '()
	    (list emacs-exwm
		  snapper
		  btrfs-progs)
	    (operating-system-packages base-system)))))


;; Evaluates into the definition above for use in 'sudo guix system reconfigure'.
taurinus-alpha-record
