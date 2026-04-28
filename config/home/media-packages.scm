(define-module (media-packages)
  #:use-module (gnu packages)
  #:export (media-packages))

(define media-packages
  (specifications->packages
   (list "mpv"
	 "vlc"
	 "obs"
	 "gimp"
	 "feh"
	 "font-jetbrains-mono"
	 "font-google-noto"
	 "font-google-noto-emoji"
	 "unclutter"
	 "playerctl"
	 "brightnessctl"
	 "xrandr"
	 "wl-clipboard"
	 "wireplumber"
	 "ffmpeg")))
