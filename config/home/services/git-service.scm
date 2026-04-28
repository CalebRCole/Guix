(define-module (services git-service)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (guix gexp)
  #:export (git-service))

(define git-service
  (simple-service 'my-git-configuration home-xdg-configuration-files-service-type
		  `(("git/config"
		     ,(plain-file "git-config"
				  "[user]
name = Caleb Cole
email = calebrylancole@gmail.com

[core]
editor = emacs

[init]
defaultBranch = main

[color]
ui = auto

[push]
autoSetupRemote = true

[hash]
algorithm = histogram")))))
