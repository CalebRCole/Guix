(define-module (emacs-packages)
  #:use-module (guix)
  #:use-module (gnu packages)
  #:use-module (nongnu packages)
  #:use-module (nongnu packages emacs)
  #:use-module (myguix packages emacs)
  #:export (emacs-packages))

(define emacs-packages
  (append
   (list emacs-org-roam-ui
	 emacs-flycheck-eglot
	 emacs-gruber-darker)
   (specifications->packages
    (list "emacs"
	  "emacs-guix"
	  "emacs-no-littering"
	  "emacs-direnv"
	  "emacs-geiser"
	  "emacs-geiser-guile"
	  "emacs-slime"
	  "emacs-doom-modeline"
	  "emacs-doom-themes"
	  "emacs-nerd-icons"
	  "emacs-highlight-indent-guides"
	  "emacs-volatile-highlights"
	  "emacs-general"
	  "emacs-vterm"
	  "emacs-eshell-git-prompt"
	  "emacs-olivetti"
	  "racket"
	  "emacs-racket-mode"
	  "emacs-ob-racket"
	  "emacs-org-superstar"
	  "emacs-pdf-tools"
	  "emacs-flycheck"
	  "emacs-jinx"
	  "hunspell-dict-en-us"
	  "enchant"
	  "emacs-vertico"
	  "emacs-marginalia"
	  "emacs-orderless"
	  "emacs-corfu"
	  "emacs-consult"
	  "emacs-consult-org-roam"
	  "emacs-consult-flycheck"
	  "emacs-consult-bibtex"
	  "emacs-consult-dir"
	  "emacs-consult-notes"
	  "emacs-consult-eglot"
	  "emacs-which-key"
	  "emacs-transient"
	  "emacs-multiple-cursors"
	  "emacs-avy"
	  "emacs-ace-window"
	  "emacs-crux"
	  "emacs-expand-region"
	  "emacs-dape"
	  "emacs-eglot"
	  "emacs-zig-mode"
	  "emacs-nix-mode"
	  "emacs-glsl-mode"
	  "emacs-haskell-mode"
	  "emacs-kanata-kbd-mode"
	  "emacs-magit"
	  "emacs-git-modes"
	  "emacs-forge"
	  "emacs-ghub"
	  "emacs-rainbow-delimiters"
	  "emacs-exec-path-from-shell"
	  "emacs-envrc"
	  "emacs-ssh-agency"
	  "emacs-helpful"
	  "book-sicp"
	  "font-abattis-cantarell"
	  "emacs-desktop-environment"))))
