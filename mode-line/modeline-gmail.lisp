(asdf:oos 'asdf:load-op '#:drakma) ; http client
(asdf:oos 'asdf:load-op '#:xmls)   ; XML parser
        
(defvar *gmail-cookies* (make-instance 'drakma:cookie-jar)
  "Contains cookies for talking to gmail server")
(defvar *gmail-username* "icylisper@gmail.com"
  "Username for gmail")
(defvar *gmail-password* "lispyindian"
  "Password for gmail")

(defun ping-gmail ()
  "Checks gmail's atom feed for new messages.  First return value is number of new messages,
       second is a list of (AUTHOR . TITLE) cons cells."
  (when (and *gmail-username* *gmail-password*)
    (multiple-value-bind (response-body response-code)
      (drakma:http-request "https://mail.google.com/mail/feed/atom" :cookie-jar *gmail-cookies*
	:basic-authorization (list *gmail-username* *gmail-password*))
      (if (= 401 response-code)
            :401-unauthorized
	(let* ((feed-tree (xmls:parse response-body))
                   (fullcount-tag (find "fullcount" (xmls:node-children feed-tree)
				    :key 'xmls:node-name :test 'equal)))
	  (assert (string= "feed" (xmls:node-name feed-tree)))
              (when (and fullcount-tag
		      (stringp (first (xmls:node-children fullcount-tag))))
                (values (or (read-from-string (first (xmls:node-children fullcount-tag)))
			  0)
		  (loop for child in (xmls:node-children feed-tree)
                              for title-tag = (when (equal (xmls:node-name child) "entry")
                                                (find "title" (xmls:node-children child)
						  :key 'xmls:node-name :test 'equal))
		    for author-tag = (when (equal (xmls:node-name child) "entry")
                                                 (find "author" (xmls:node-children child)
						   :key 'xmls:node-name :test 'equal))
                              when (and title-tag author-tag)
		    collect (cons
			      (first (xmls:node-children (first (xmls:node-children author-tag))))
                                       (first (xmls:node-children title-tag)))))))))))

(defparameter *gmail-show-titles* nil
      "When non-NIL, show the authors and titles whenever new mail arrives.")
(defparameter *gmail-ping-period* (* 2 60 internal-time-units-per-second)
  "Time between each gmail server ping")
        
(defvar *gmail-last-ping* 0
      "The internal time of the latest ping of the gmail server")
(defvar *gmail-last-value* nil
      "The result of the latest ping of the gmail server")
        
(defun format-gmail (stream)
      "Formats to STREAM a string representing the current status of the gmail mailbox.  Uses cached
          values if it is called more frequently than once every *GMAIL-PING-PERIOD*.  When new mail
          arrives, this function will also display a message containing all the current inbox items"
  (when (> (- (get-internal-real-time)
	     *gmail-last-ping*)
	  *gmail-ping-period*)
    (multiple-value-bind (num-msgs msg-summaries)
      (ping-gmail)
      (when (and *gmail-show-titles*
	      num-msgs (> num-msgs 0)
	      (or (null *gmail-last-value*)
                         (/= num-msgs *gmail-last-value*)))
	(let ((*timeout-wait* (* *timeout-wait* (min 2 num-msgs)))) ; leave time to read the titles
	  (message "~A"
	    (with-output-to-string (s)
	      (loop for (author . title) in msg-summaries
		do (format s "~A - ~A~%" author title))))))
      (setf *gmail-last-value* num-msgs
	*gmail-last-ping* (get-internal-real-time))))
  (cond
    ((null *gmail-last-value*)
      (format stream "[mail:???]"))
    ((and (numberp *gmail-last-value*)
       (zerop *gmail-last-value*))
      (format stream "[mail: 0]"))
    ((numberp *gmail-last-value*)
      (format stream "[MAIL:~2D]" *gmail-last-value*))
    (t
      (format stream "[mail:ERR]"))))

;(setf *screen-mode-line-format* (list "%w   "  ;; ... some other modeline settings ...  '(:eval (format-gmail nil))))