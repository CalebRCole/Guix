(define-module (base-system)
  #:use-module (guix)
  #:use-module (gnu)
  #:use-module ((nongnu packages linux) #:prefix nongnu:)
  #:use-module (nongnu system linux-initrd)
  #:export (base-system %my-user))

(use-service-modules cups desktop networking ssh xorg)
(use-package-modules bootloaders certs shells emacs base version-control wm)

(define %my-user "ccole")

(define base-system
  (operating-system
   (kernel nongnu:linux)
   (initrd microcode-initrd)
   (firmware (list nongnu:linux-firmware))
   (locale "en_US.utf8")
   (timezone "America/Detroit")
   (keyboard-layout (keyboard-layout "us"))
   (host-name "Base")
   
   ;; 'root' is implicit
   (users (cons* (user-account
                  (name %my-user)
                  (comment "Caleb Cole")
                  (group "users")
                  (home-directory "/home/ccole")
                  (supplementary-groups '("wheel" "netdev" "audio" "video" "input" "uinput")))
                 %base-user-accounts))

   (groups (cons* (user-group (name "uinput") (system? #t))
                 %base-groups))

   (services
    (append (list (service gnome-desktop-service-type)
                  ;; To configure OpenSSH, pass an 'openssh-configuration'
                  ;; record as a second argument to 'service' below.
                  (service openssh-service-type)
                  (service tor-service-type)
                  (service cups-service-type)
		  (udev-rules-service 'uinput 
				      (udev-rule "99-uinput.rules"
						 "KERNEL==\"uinput\", MODE=\"0660\", GROUP=\"uinput\", OPTIONS+=\"static_node=uinput\""))
                  (set-xorg-configuration
                   (xorg-configuration (keyboard-layout keyboard-layout))))
	    %desktop-services))

   (bootloader (bootloader-configuration
		(bootloader grub-efi-bootloader)
		(targets (list "/boot/efi"))
		(keyboard-layout keyboard-layout)))

   (initrd-modules (append '("vmd") %base-initrd-modules))

   (file-systems %base-file-systems)

   (packages %base-packages)))
