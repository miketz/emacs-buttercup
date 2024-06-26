;;; buttercup-compat.el --- Compatibility definitions for buttercup  -*- lexical-binding: t; -*-

;; Copyright (C) 2015  Jorgen Schaefer
;; Copyright (C) 2015  Free Software Foundation, Inc.

;; Author: Jorgen Schaefer <contact@jorgenschaefer.de>

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This file provides compatibility definitions for buttercup. These
;; are primarily backported features of later versions of Emacs that
;; are not available in earlier ones.

;; Most parts of this file are taken from the Emacs source code to
;; provide the same functionality.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;
;;; Introduced in 25.1

(when (not (fboundp 'directory-files-recursively))
  (defun directory-files-recursively (dir match &optional include-directories)
    "Return all files under DIR that have file names matching MATCH (a regexp).
This function works recursively.  Files are returned in \"depth first\"
and alphabetical order.
If INCLUDE-DIRECTORIES, also include directories that have matching names."
    (let ((result nil)
          (files nil)
          ;; When DIR is "/", remote file names like "/method:" could
          ;; also be offered.  We shall suppress them.
          (tramp-mode (and tramp-mode (file-remote-p dir))))
      (dolist (file (sort (file-name-all-completions "" dir)
                          #'string<))
        (unless (member file '("./" "../"))
          (if (directory-name-p file)
              (let* ((leaf (substring file 0 (1- (length file))))
                     (full-file (expand-file-name leaf dir)))
                ;; Don't follow symlinks to other directories.
                (unless (file-symlink-p full-file)
                  (setq result
                        (nconc result (directory-files-recursively
                                       full-file match include-directories))))
                (when (and include-directories
                           (string-match match leaf))
                  (setq result (nconc result (list full-file)))))
            (when (string-match match file)
              (push (expand-file-name file dir) files)))))
      (nconc result (nreverse files)))))

(when (not (fboundp 'directory-name-p))
  (defsubst directory-name-p (name)
    "Return non-nil if NAME ends with a slash character."
    (and (> (length name) 0)
         (char-equal (aref name (1- (length name))) ?/))))

(when (not (fboundp 'seconds-to-string))
  (defvar seconds-to-string
	(list (list 1 "ms" 0.001)
          (list 100 "s" 1)
          (list (* 60 100) "m" 60.0)
          (list (* 3600 30) "h" 3600.0)
          (list (* 3600 24 400) "d" (* 3600.0 24.0))
          (list nil "y" (* 365.25 24 3600)))
	"Formatting used by the function `seconds-to-string'.")
  (defun seconds-to-string (delay)
	"Convert the time interval in seconds to a short string."
	(cond ((> 0 delay) (concat "-" (seconds-to-string (- delay))))
          ((= 0 delay) "0s")
          (t (let ((sts seconds-to-string) here)
               (while (and (car (setq here (pop sts)))
                           (<= (car here) delay)))
               (concat (format "%.2f" (/ delay (car (cddr here)))) (cadr here)))))))

;;;;;;;;;;;;;;;;;;;;;;
;;; Introduced in 26.1

(unless (fboundp 'file-attribute-modification-time)
  (defsubst file-attribute-modification-time (attributes)
	"The modification time in ATTRIBUTES returned by `file-attributes'.
This is the time of the last change to the file's contents, and
is a Lisp timestamp in the style of `current-time'."
	(nth 5 attributes)))

;;;;;;;;;;;;;;;;;;;;;;
;;; Introduced in 28.1

(unless (fboundp 'with-environment-variables)
  (defmacro with-environment-variables (variables &rest body)
    "Set VARIABLES in the environment and execute BODY.
VARIABLES is a list of variable settings of the form (VAR VALUE),
where VAR is the name of the variable (a string) and VALUE
is its value (also a string).

The previous values will be restored upon exit."
    (declare (indent 1) (debug (sexp body)))
    (unless (consp variables)
      (error "Invalid VARIABLES: %s" variables))
    `(let ((process-environment (copy-sequence process-environment)))
       ,@(mapcar (lambda (elem)
                   `(setenv ,(car elem) ,(cadr elem)))
                 variables)
       ,@body)))

;;;;;;;;;;;;;;;;;;;;;;
;;; Introduced in 29.1

(unless (boundp 'backtrace-on-error-noninteractive)
  (defvar backtrace-on-error-noninteractive nil
	"Control early backtrace starting in Emacs 29."))

(provide 'buttercup-compat)
;; Local Variables:
;; indent-tabs-mode: nil
;; tab-width: 8
;; sentence-end-double-space: nil
;; End:
;;; buttercup-compat.el ends here
