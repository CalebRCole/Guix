(define-module (programming-packages)
  #:use-module (guix)
  #:use-module (gnu packages)
  #:use-module (emacs-packages)
  #:use-module (language-packages)
  #:export (programming-packages))

(define programming-packages
  (append emacs-packages
	  language-packages
	  (specifications->packages (list "alacritty"
					  "git"
					  "vim"
					  "valgrind"
					  "strace"
					  "wget"
					  "curl"
					  "nmap"
					  "guile-readline"
					  "guile-colorized"
					  "fzf"
					  "fd"
					  "ripgrep"
					  "direnv"))))
