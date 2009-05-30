(defvar *prev-user-cpu* 0)
(defvar *prev-sys-cpu* 0)
(defvar *prev-idle-cpu* 0)
(defvar *prev-iowait* 0)

(defun current-cpu-usage ()
  "Return the average CPU usage since the last call.
       First value is percent of CPU in use.
       Second value is percent of CPU in use by system processes.
       Third value is percent of time since last call spent waiting for IO (or 0 if not available)."
  (let ((cpu-result 0)
        (sys-result 0)
        (io-result nil))
    (with-open-file (in "/proc/stat" :direction :input)
      (if (eq 'cpu (read in))
          (let* ((norm-user (read in))
                 (nice-user (read in))
                 (user (+ norm-user nice-user))
                 (sys (read in))
                 (idle (read in))
                 (iowait (or (ignore-errors (read in)) 0))
                 (step-denom (- (+ user sys idle iowait)
                                (+ *prev-user-cpu* *prev-sys-cpu* *prev-idle-cpu* *prev-iowait*))))
            (setf cpu-result (/ (- (+ user sys)
                                   (+ *prev-user-cpu* *prev-sys-cpu*))
                                step-denom)
                  sys-result (/ (- sys *prev-sys-cpu*)
                                step-denom)
                  io-result (/ (- iowait *prev-iowait*)
                               step-denom)
                  *prev-user-cpu* user
                  *prev-sys-cpu* sys
                  *prev-idle-cpu* idle
                  *prev-iowait* iowait))
          (warn "Unexpected header")))
    (values cpu-result sys-result io-result)))

(defun format-current-cpu-usage (stream)
  "Formats a string representing the current processor usage to STREAM.
       Arguments are as those to FORMAT, so NIL returns a formatted string and T prints to standard
       output."
  (multiple-value-bind (cpu sys io) (current-cpu-usage)
    (declare (ignore sys))
    (format stream "[cpu:~3D%] [io:~3D%]" (truncate (* 100 cpu)) (if io (truncate (* 100 io)) 0))))

;;     (setf *screen-mode-line-format* (list "%w   "
;;                                           ;; ... some other modeline settings ...
;;                                           '(:eval (format-current-cpu-usage nil))))