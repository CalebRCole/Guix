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
  #:use-module (gnu packages wm)
  #:use-module ((nongnu packages linux) #:prefix nongnu:)
  #:use-module (nongnu system linux-initrd)
  #:use-module (services btrfs-service)
  #:use-module (base-system)
  #:export (taurinus-alpha-record))

;; List of directories to be bind-mounted.
(define %system-bind-mounts '("/var/log"
			      "/var/lib"
			      "/etc/ssh"
			      "/etc/cups"
			      "/etc/snapper/configs"
			      "/etc/default/snapper"
			      "/etc/NetworkManager/system-connections"))
(define %home-bind-mounts   '("Documents"
			      "Music"
			      "Projects"
			      "Pictures"
			      "Templates"
			      "Videos"
			      ".gnupg"
			      ".mozilla"
			      ".tor project"
			      ".ssh"
			      ".local/state/shepherd"
			      ".local/share/direnv"
			      ".local/share/Trash"
			      ".config/librewolf"
			      ".config/emacs"
			      ".cache/emacs"
			      ".cache/guix"))

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
    (append (list
	     ;; Partitions/Sub-volumes
	     ;; Ephemeral root.
  	     (file-system
	      (mount-point "/")
	      (device "none")
	      (type "tmpfs")
	      (create-mount-point? #t)
	      (needed-for-boot? #t)
	      (check? #f)
	      (flags '(no-dev no-atime no-suid))
	      (options "size=25%,mode=755"))

 	     ;; Boot partition.
	     (file-system
  	      (mount-point "/boot/efi")
  	      (device (file-system-label "BOOT"))
  	      (type "vfat")
	      (create-mount-point? #t)
	      (needed-for-boot? #t)
	      (flags '(no-exec))
	      (options "umask=0077"))

  	     ;; Mounting for the store.
  	     (file-system
  	      (mount-point "/gnu")
  	      (device "/dev/mapper/Guix")
  	      (type "btrfs")
	      (create-mount-point? #t)
  	      (needed-for-boot? #t)
  	      (flags '(no-atime))
  	      (options "subvol=@gnu,compress=zstd,space_cache=v2")
  	      (dependencies mapped-devices))

	     ;; Persistence sub-volume.
	     (file-system
	      (mount-point "/persist")
	      (device "/dev/mapper/Guix")
	      (type "btrfs")
	      (needed-for-boot? #t)
	      (create-mount-point? #t)
	      (flags '(no-atime no-suid))
	      (options "subvol=@persist,compress=zstd,space_cache=v2")
	      (dependencies mapped-devices)))

	    ;; System Bind-Mounts
	    (map (lambda (path)
		   (file-system
		    (mount-point path)
		    (device (string-append "/persist" path))
		    (type "btrfs")
		    (create-mount-point? #t)
		    (needed-for-boot? #t)
		    (flags '(bind-mount))
		    (dependencies (list (car (filter (lambda (fs)
						       (string=? (file-system-mount-point fs) "/persist"))
						     %base-file-systems))))))
		 %system-bind-mounts)

	     ;; Home Bind-Mounts
	    (map (lambda (path)
		   (file-system
		    (mount-point (string-append "/home/" %my-user "/" path))
		    (device (string-append "/persist/home/" %my-user "/" path))
		    (type "btrfs")
		    (create-mount-point? #t)
		    (flags '(bind-mount))
		    (dependencies (list (car (filter (lambda (fs)
						       (string=? (file-system-mount-point fs) "/persist"))
						     %base-file-systems))))))
		 %home-bind-mounts)
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
		     sway
		     snapper
		     btrfs-progs)
	       (operating-system-packages base-system)))))


;; Evaluates into the definition above for use in 'sudo guix system reconfigure'.
taurinus-alpha-record
