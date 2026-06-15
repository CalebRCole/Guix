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

;; Exported for use in generating an image for system installation.
(define taurinus-alpha-record
  (operating-system
   (inherit base-system)
   (host-name "taurinus-alpha")

   (mapped-devices (list (mapped-device
			  (source (uuid "72859a88-811b-456e-98d6-40e34fc39ed0"))
			  (target "Guix")
			  (type luks-device-mapping))))

   (file-systems
    (let* ((persist (file-system
		     (mount-point "/persist")
		     (device "/dev/mapper/Guix") ; Points to the unlocked LUKS device
		     (type "btrfs")
		     (needed-for-boot? #t)
		     (create-mount-point? #t)
		     (flags '(no-atime no-suid))
		     (options "subvol=@persist,compress=zstd,space_cache=v2")
		     (dependencies mapped-devices))))
      (append (list 
	       ;; Root volume. Gets overwritten by blank root sub-volume.
  	       (file-system
		(mount-point "/")
		(device "none")
		(type "tmpfs")
		(needed-for-boot? #t)
		(flags '(no-dev no-atime no-suid))
		(options "size=25%,mode=755"))

 	       ;; Boot partition.
	       (file-system
  		(mount-point "/boot/efi")
  		(device (file-system-label "BOOT"))
  		(type "vfat")
		(needed-for-boot? #t)
		(flags '(no-exec))
		(options "umask=0077"))

  	       ;; Mounting for the store.
  	       (file-system
  		(mount-point "/gnu")
  		(device "/dev/mapper/Guix")
  		(type "btrfs")
  		(needed-for-boot? #t)
  		(flags '(no-atime))
  		(options "subvol=@gnu,compress=zstd,space_cache=v2")
  		(dependencies mapped-devices))

	       ;; Persistence sub-volume.
	       persist

	       (file-system
		(device "/persist/var/log")
		(mount-point "/var/log")
		(type "none")
		(create-mount-point? #t)
		(needed-for-boot? #t)
		(flags '(bind-mount))
		(shepherd-requirements '(file-system-/persist))))

	       %base-file-systems)))

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
