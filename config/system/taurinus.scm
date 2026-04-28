(define-module (taurinus)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (guix transformations)
  #:use-module (gnu services pm)
  #:use-module ((nongnu packages linux) #:prefix nongnu:)
  #:use-module (nongnu system linux-initrd)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (base-system))

(operating-system
 (inherit base-system)
 (host-name "taurinus")

 (mapped-devices (list (mapped-device
                        (source (uuid
                                 "8d598765-ccb3-4ba1-97aa-ef8f93d6929f"))
                        (target "cryptroot")
                        (type luks-device-mapping))
                       (mapped-device
                        (source (uuid
                                 "7c58044f-ab80-43bf-9c77-3d52dd95558e"))
                        (target "crypthome")
                        (type luks-device-mapping))))

 (file-systems (cons* (file-system
                       (mount-point "/boot/efi")
                       (device (uuid "FB3D-B7E6"
                                     'fat32))
                       (type "vfat"))
                      (file-system
                       (mount-point "/")
                       (device "/dev/mapper/cryptroot")
                       (type "ext4")
                       (dependencies mapped-devices))
                      (file-system
                       (mount-point "/home")
                       (device "/dev/mapper/crypthome")
                       (type "ext4")
                       (dependencies mapped-devices))
        	      %base-file-systems))

 (services
  (append (list
	   (service tlp-service-type
		    (tlp-configuration
		     (cpu-boost-on-ac? #t)
		     (wifi-pwr-on-bat? #t))))
	  (operating-system-user-services base-system)))

 (packages
  (append '()
	  (list emacs-exwm)
	  (operating-system-packages base-system))))
