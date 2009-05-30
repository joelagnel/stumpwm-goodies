;;; Date formatters for the mode-line
;;;
;;; Copyright 2007 Anonymous Coward, Jonathan Moore Liles, Morgan Veyret.
;;;
;;; This module is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2, or (at your option)
;;; any later version.
;;;
;;; This module is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this software; see the file COPYING.  If not, write to
;;; the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
;;; Boston, MA 02111-1307 USA
;;;

;;; USAGE:
;;;
;;; Put:
;;;
;;;     (load "/path/to/date.lisp")
;;;
;;; In your ~/.stumpwmrc
;;;
;;; Then you can use "%D %d" in your mode line format.
;;;
;;; NOTES:
;;;
;;;

(in-package :stumpwm)

;; Install formatters.
(dolist (a '((#\d fmt-time)
             (#\D fmt-date)))
  (push a *screen-mode-line-formatters*))

(defvar *days-of-week*
  '("Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday"))


(defun fmt-date (ml)
  "Returns a string representing current the percent of average CPU
  utilization."
  (declare (ignore ml))
  (multiple-value-bind (second minute hour date month year dow)
      (decode-universal-time (get-universal-time) )
    (format nil "~A ~A/~A/~A"
            (nth dow *days-of-week*) date month year hour minute second)))


(defun fmt-time (ml)
  "Returns a string representing current the percent of average CPU
  utilization."
  (declare (ignore ml))
  (multiple-value-bind (second minute hour date month year dow)
      (decode-universal-time (get-universal-time) )
    (format nil "~A:~A:~A"
            hour minute second)))
