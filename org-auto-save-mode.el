;; org-auto-save-mode.el --- Auto-save org buffers, based on your activity. -*- lexical-binding: t -*-

;; Copyright © 2017 Martin Balfanz <info@martinbalfanz.com>

;; Author: Martin Balfanz <info@martinbalfanz.com>
;; URL: https://github.com/martinbalfanz/
;; Package-Version: 20180410.1
;; Keywords: convenience, org, agenda
;; Version: 0.1.0
;; Package-Requires: ((emacs "25.1") (org "9.0"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; org-autosave saves buffers when certain actions are performed,
;; e.g. refiling
;;
;; It is very closely modeled after Bozhidar Batsov's super-save,
;; https://github.com/bbatsov/super-save
;;
;;; Code:
(require 'org)

(defgroup org-auto-save nil
  "Auto-saving of org-buffers."
  :group 'org
  :group 'convenience
  :link '(url-link "http://github.com/martinbalfanz/org-auto-save"))

(defvar org-auto-save-mode-map (make-sparse-keymap)
  "org-autosave mode's keymap.")

(defcustom org-auto-save-triggers
  '("org-agenda-todo" "org-agenda-priority"
    "org-refile" "org-schedule" "org-deadline" "org-set-tags")
  "A list of commands which trigger `org-auto-save-command'."
  :group 'org-auto-save
  :type '(repeat string))

(defun org-auto-save-command-advice (&rest _args)
  "A simple wrapper around `org-save-all-org-buffers' that's advice-friendly."
  (org-save-all-org-buffers))

(defun org-auto-save-advice-trigger-commands ()
  "Apply org-auto-save to the commands listed in `org-auto-save-triggers'."
  (mapc (lambda (command)
          (advice-add (intern command) :after #'org-auto-save-command-advice))
        org-auto-save-triggers))

(defun org-auto-save-remove-advice-from-trigger-commands ()
  "Remove org-auto-save advice from to the commands listed in `org-auto-save-triggers'."
  (mapc (lambda (command)
          (advice-remove (intern command) #'org-auto-save-command-advice))
        org-auto-save-triggers))

;;;###autoload
(define-minor-mode org-auto-save-mode
  "A minor mode that saves your org buffers when you run common org commands."
  :lighter " org-auto-save"
  :keymap org-auto-save-mode-map
  :group 'org-auto-save
  (cond
   (org-auto-save-mode (org-auto-save-advice-trigger-commands))
   (t (org-auto-save-remove-advice-from-trigger-commands))))

(provide 'org-auto-save-mode)
