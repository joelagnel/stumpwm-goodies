;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Joel Agnel Fernandes
;; initramd@gmail.com
;; Description: Multimedia key mappings for stumpwm
;; suggestions/patches welcomed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package :stumpwm)

;; KEY DEFINITION - Key code symbol table
;; note: certain keyboards have this different. use xev to find yours if these don't work
(setf *key-codes*
      '((162 . "XF86AudioPlay")		   ; handled by amarok (or other mp3 players)
	(164 . "XF86AudioStop")		   
	(144 . "XF86AudioPrev")
	(153 . "XF86AudioNext")
	(160 . "XF86AudioMute")
	(174 . "XF86AudioLowerVolume")	   ; we use amixer (alsa mixer) to  handle this
	(176 . "XF86AudioRaiseVolume")))

;; Map keycodes to keysyms
(mapcar (lambda (pair)
	  (let* ((keycode (car pair))
		 (keysym  (cdr pair))
		 (format-dest nil)
		 (format-dest (make-array 5 :fill-pointer 0 :adjustable t :element-type 'character)))
	    (format format-dest "xmodmap -e 'keycode ~d = ~a'" keycode keysym)
	    (run-shell-command format-dest)
	  format-dest))
	*key-codes*)

;; Volume control
(define-key stumpwm:*top-map* (stumpwm:kbd "XF86AudioLowerVolume") "exec amixer set Master 5%-")
(define-key stumpwm:*top-map* (stumpwm:kbd "XF86AudioRaiseVolume") "exec amixer set Master 5%+")

;; Mute
(define-key stumpwm:*top-map* (stumpwm:kbd "XF86AudioMute") "exec amixer set Master toggle")
