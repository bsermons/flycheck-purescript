;;; flycheck-purescript.el --- Flycheck support for the purescript language

;; Copyright (c) 2015 Brian Sermons

;; Author: Brian Sermons
;; Package-Requires: ((flycheck "0.24") (emacs "24.4"))
;; URL: https://github.com/bsermons/flycheck-purescript

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Usage: (eval-after-load 'flycheck
;;;          '(add-hook 'flycheck-mode-hook #'flycheck-purescript-setup))

;;; Code:

(require 'cl-lib)
(require 'json)
(require 'flycheck)

(defgroup flycheck-purescript nil
  "Purescript support for Flycheck."
  :prefix "flycheck-purescript-"
  :group 'flycheck
  :link '(url-link :tag "Github" "https://github.com/bsermons/flycheck-purescript"))

(defcustom flycheck-purescript-reporting-mode 'all
  "*Types of messages to show."
  :type '(choice
          (const :tag "Show warnings and errors." all)
          (const :tag "Show only errors." errors-only)
          (const :tag "Show warnings only if no errors occur." warn-after-errors))
  :group 'flycheck-purescript)

(defcustom flycheck-purescript-ignored-error-codes nil
  "List of errors codes to ignore."
  :type '(repeat string)
  :group 'flycheck-purescript)

(defcustom flycheck-purescript-compiler-options
    '("--json-errors" "--no-magic-do" "--no-tco" "--no-opts" "-v")
    "Compiler options to send to the purescript compiler."
    :type '(repeat string)
    :group 'flycheck-purescript)

(defcustom flycheck-purescript-glob-patterns
    '("bower_components/*/src/**/*.purs" "src/**/*.purs")
    "Glob patterns to send to the purescript compiler."
  :type '(repeat string)
  :group 'flycheck-purescript)


(defun flycheck-purescript-decode-purescript-error (checker buffer type error)
  "Decode a purescript json error and convert it to the flycheck error format."
  (let* ((position (assoc 'position error))
         (start-line (cdr (assoc 'startLine position)))
         (start-col (cdr (assoc 'startColumn position)))
         (end-line (cdr (assoc 'endLine position)))
         (end-col (cdr (assoc 'endColumn position)))
         (error-code (cdr (assoc 'errorCode error))))
    (when (not (-contains? flycheck-purescript-ignored-error-codes error-code))
      (flycheck-error-new
       :checker checker
       :buffer buffer
       :filename (cdr (assoc 'filename error))
       :line start-line
       :column start-col
       :message (cdr (assoc 'message error))
       :level type))))

(defun flycheck-purescript-read-json (str)
  (let* ((json-array-type 'list))
    (condition-case nil
        (json-read-from-string str)
      (error nil))))

(defun flycheck-purescript-parse-errors (output checker buffer)
  "Decode purescript json output errors."
  (let* ((data (flycheck-purescript-read-json output))
         (errors (mapcar
                  (lambda (x) (flycheck-purescript-decode-purescript-error checker buffer 'error x))
                  (cdr (assoc 'errors data))))
         (warnings (mapcar
                    (lambda (x) (flycheck-purescript-decode-purescript-error checker buffer 'warning x))
                    (cdr (assoc 'warnings data)))))
    (pcase flycheck-purescript-reporting-mode
      (`errors-only errors)
      (`warn-after-errors
       (pcase (length errors)
         (0 warnings)
         (t errors)))
      (_  (append errors warnings)))))


(flycheck-define-checker purescript
  "A syntax checker for purescript-mode using the json output from psc"
  :command ("psc"
            (eval flycheck-purescript-compiler-options)
            (eval flycheck-purescript-glob-patterns))
  :error-parser flycheck-purescript-parse-errors
  :modes purescript-mode)

;;;###autoload
(defun flycheck-purescript-setup ()
  "Setup Flycheck purescript."
  (interactive)
  (add-to-list 'flycheck-checkers 'purescript))

(provide 'flycheck-purescript)
;;; flycheck-purescript.el ends here
