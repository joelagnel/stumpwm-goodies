(in-package :stumpwm)

(defun update-mode-line ()
  (redraw-mode-line-for 
    (screen-mode-line (current-screen))
    (current-screen))
  (resize-mode-line-for 		    
    (screen-mode-line (current-screen))
    (current-screen)))


(defun show-battery-charge ()
  (let ((raw-battery (run-shell-command "acpi | cut -d, -f2" t))) 
    (substitute #\Space #\Newline raw-battery)))

(defun show-time ()
  (let ((time (multiple-value-list (get-decoded-time))))
    (format nil "~2,'0d:~2,'0d " 
	    (third time)
	    (second time))))

(defun load-str ()
  (with-open-file (loadavg "/proc/loadavg")
    (cl-ppcre:scan-to-strings "^\\d+\\.\\d+ \\d+\\.\\d+ \\d+\\.\\d+" (read-line loadavg))))

;;    " | "
;;     "(load " '(:eval (load-str)) ")"


(defun show-mldonkey-stats ()
  (substitute #\Space #\Newline (run-shell-command "mldonkey_command vd | grep Down: | cut -d'|' -f1,2" t)))


(setf *screen-mode-line-format*
      (list '(:eval (show-time))    "|"
	    '(:eval (show-battery-charge)) "| "
	    '(:eval (show-mldonkey-stats)) "| "))



