(define-module (taurinus-alpha)
  #:use-module (guix)
  #:use-module (guix gexp)
  #:use-module (guix transformations)
  #:use-module (gnu)
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

;; The path of a directory should be the same on btrfs as with tmpfs, just with /mnt/persist/ prepended
(define (persistent-subvolume path dependency)
  (file-system
   (device (string-append "/mnt/persist/" path))
   (mount-point (string-append "/" path))
   (type "none")
   (flags '(bind-mount))
   (create-mount-point? #t)
   (needed-for-boot? #t)
   (dependencies (list dependency))))

;; Only for /home/ volumes. %my-user is exported by (base-system).
(define (persistent-home-subvolume path dependency)
  (file-system
   (device (string-append "/mnt/persist/home/user/" path))
   (mount-point (string-append "/home/" %my-user "/" path))
   (type "none")
   (flags '(bind-mount))
   (create-mount-point? #t)
   (needed-for-boot? #t)
   (dependencies (list dependency))))

;; Exported for use in generating an image for system installation.
(define taurinus-alpha-record
  (operating-system
   (inherit base-system)
   (host-name "taurinus-alpha")

   (mapped-devices (list (mapped-device
			  (source "/dev/nvme0n1p2")
			  (target "persist")
			  (type luks-device-mapping))))

   (file-systems
    (let ((persist (file-system
  		    (mount-point "/mnt/persist")
  		    (device "/dev/mapper/persist")
  		    (type "btrfs")
  		    (needed-for-boot? #t)
  		    (flags '(no-atime no-suid))
  		    (options "subvol=@persist,compress=zstd,space_cache=v2")
  		    (dependencies mapped-devices))))
      (append (list
  	       ;; Boot partition.
  	       (file-system
  		(mount-point "/boot/efi")
  		(device (file-system-label "boot"))
  		(type "vfat")
		(needed-for-boot? #t)
		(flags '(no-exec))
		(options "umask=0077"))

  	       ;; Ram-based root filesystem enforces impermanence.
  	       (file-system
  		(mount-point "/")
  		(device "none")
  		(type "tmpfs")
  		(check? #f)
  		(flags '(no-dev no-atime no-suid))
  		(options "size=25%,mode=0755"))

  	       ;; Mounting for the store.
  	       (file-system
  		(mount-point "/gnu/store")
  		(device "/dev/mapper/persist")
  		(type "btrfs")
  		(needed-for-boot? #t)
  		(flags '(no-atime read-only))
  		(options "subvol=@store,compress=zstd,space_cache=v2")
  		(dependencies mapped-devices))

  	       ;; Mounting for all persistent data.
  	       persist)

	      ;;; Bind-mounts		
	      ;; System-mounts. "/mnt/persist/" is already prepended to volumes on btrfs.
	      (map (lambda (paths)
		     (persistent-subvolume paths persist))
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

  	      ;; Home-mounts
	      (map (lambda (paths)
		     (persistent-home-subvolume paths persist))
		   (list "Projects"
			 "Documents"
			 "Pictures"
			 "Music"
			 "Videos"
			 "Templates"
			 ".ssh"
			 ".gnupg"
			 ".mozilla"		 ; Firefox
			 ".tor project"		 ; Tor
			 ".local/state/shephard" ; Shepherd Logs
			 ".local/share/direnv"   ; Direnv
			 ".local/share/Trash"	 ; XDG trash dir
			 ".config/librewolf"	 ; Librewolf Config (Extensions, etc.)
			 ".config/emacs"	 ; Emacs Config
			 ".cache/emacs"		 ; Emacs Cache
			 ".cache/guix"		 ; Guix Cache
			 ))
	      (filter (lambda (fs)
			(let ((mp (file-system-mount-point fs)))
                          (not (member mp '("/" "/boot/efi")))))
		      %base-file-systems))))

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
