(define-module (taurinus-alpha)
  #:use-module (guix)
  #:use-module (guix gexp)
  #:use-module (guix build utils)
  #:use-module (guix transformations)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu services pm)
  #:use-module (gnu services authentication)
  #:use-module (gnu services linux)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages file-systems)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages window-management)
  #:use-module ((nongnu packages linux) #:prefix nongnu:)
  #:use-module (nongnu system linux-initrd)
  #:use-module (services btrfs-service)
  #:use-module (base-system)
  #:export (taurinus-alpha-record))

;; Exported for use in generating an image for system installation.
(define taurinus-alpha-record
  (operating-system
   (inherit base-system)
   (host-name "taurinus-alpha")

   (mapped-devices
    (list (mapped-device
	   (source (uuid "72859a88-811b-456e-98d6-40e34fc39ed0"))
	   (target "Guix")
	   (type luks-device-mapping))))

   (file-systems
    (cons* 
     ;; Boot partition.
     (file-system
      (mount-point "/boot/efi")
      (device (file-system-label "BOOT"))
      (type "vfat")
      (create-mount-point? #t)
      (needed-for-boot? #t)
      (flags '(no-exec))
      (options "umask=0077"))

     ;; Data sub-volume.
     (file-system
      (mount-point "/")
      (device "/dev/mapper/Guix")
      (type "btrfs")
      (needed-for-boot? #t)
      (create-mount-point? #t)
      (flags '(no-atime no-suid))
      (options "compress=zstd,space_cache=v2")
      (dependencies mapped-devices))

     %base-file-systems))

   (swap-devices
    (list (swap-space
	   (target "/swapfile")
	   (dependencies (filter (file-system-mount-point-predicate "/persist")
				 file-systems)))))

   (services
    (append (list (service tlp-service-type
  			   (tlp-configuration
  			    (cpu-boost-on-ac? #t)
  			    (wifi-pwr-on-bat? #t)))
		  (service fprintd-service-type)
		  (service zram-device-service-type
			   (zram-device-configuration
			    (size "100%")
			    (compression-algorithm 'zstd)
			    (priority 100))))
	    btrfs-service
	    (operating-system-user-services base-system)))

   (packages
    (append (list sway
		  snapper
		  btrfs-progs)
	    (operating-system-packages base-system)))))


;; Evaluates into the definition above for use in 'sudo guix system reconfigure'.
taurinus-alpha-record
