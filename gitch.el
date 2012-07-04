;;; gitch.el --- Automatically open and close buffers when switching git
;;               branches, using git-emacs and desktop.el.
;;
;; Author: Rutger Prins <rutger@rutgerprins.net>
;;
;;
;; Requirements:
;; - git-emacs    https://github.com/tsgates/git-emacs
;; - desktop.el   http://repo.or.cz/w/emacs.git/blob/HEAD:/lisp/desktop.el
;;
;; Install:
;; - Place this file in your .emacs.d/ directory.
;; Then add this to your .emacs file:
;; - (load-file "~/.emacs.d/gitch.el")``
;; - (setq gitch-current-repository "~/my-project/")``
;;
;; Usage:
;; - M-x gitch-switch-branch:
;;          1. Switch to a branch.
;;          2. Close all current buffers.
;;          3. Open buffers that were previously open for this branch.
;; - M-x gitch-save: Save buffers for the current branch.
;; - M-x gitch-load: Load buffers for the current branch.
;; - M-x gitch-new:  Save buffers, checkout new branch.
;;


;; Optional hooks:
;(add-hook 'emacs-startup-hook 'gitch-load-buffers)
;(add-hook 'kill-emacs-hook 'gitch-save-buffers)


;; Set optimal Desktop settings:
(setq desktop-buffers-not-to-save "^*.+*$")
(setq desktop-clear-preserve-buffers (quote ("\\*.*\\*")))
(setq desktop-load-locked-desktop t)


(defcustom gitch-current-repository "."
  "The current git repository (a directory).
   Can be changed using 'gitch-switch-repository."
  :type 'directory)

(defcustom gitch-desktop-dir (concat user-emacs-directory "gitch/desktops/")
  "Where gitch stores its desktop files."
  :type 'directory)


(defun gitch-switch-branch (&optional branch)
  "Stash any pending changes and switch to another git branch.
   Pop stash relevant for this branch and open any buffers that were
  previously open."
  (interactive)
  (cd gitch-current-repository)
  (let ((branch (or branch (git--select-branch (git--current-branch)))))
    (gitch-save-buffers)
    (gitch--stash)
    (git-switch-branch branch)
    (desktop-clear)
    (gitch--stash-pop-for-branch branch)
    (gitch-load-buffers)))

(defun gitch-switch-repository (repository)
  "Close the current buffers and open buffers for the current branch
   of the new repository, if it was visited previously."
  (interactive "DSelect a git repository: ")
  (gitch-save-buffers)
  (cd repository)
  (set 'gitch-current-repository (git--get-top-dir))
  (desktop-clear)
  (gitch-load-buffers))

(defun gitch-load-buffers ()
  (interactive)
  (gitch--desktop-do 'desktop-read))

(defun gitch-save-buffers ()
  (interactive)
  (gitch--desktop-do 'desktop-save))

(defun gitch-new-branch (new-branch)
  (interactive "sNew branch name: ")
  (progn
    (gitch-save-buffers)
    (gitch--stash)
    (git-checkout-to-new-branch new-branch "master")
    (desktop-clear)
    (gitch-load-buffers)))

(defun gitch--repository-name ()
  (car (last (split-string (git--get-top-dir) "/" t))))

(defun gitch--current-desktop ()
  "Return the desktop file for the current repository and branch"
  (progn
    (cd gitch-current-repository)
    (concat gitch-desktop-dir (gitch--repository-name) "/" (git--current-branch))))

(defun gitch--desktop-do (desktop-func)
  (let ((current-desktop (gitch--current-desktop)))
    (if (not (file-exists-p current-desktop))
        (make-directory current-desktop t)
      (funcall desktop-func current-desktop))))

(defun gitch--stash ()
  (shell-command "git stash"))

(defun gitch--stash-pop-for-branch (branch)
  (let ((stash-list (shell-command-to-string "git stash list"))
        (stash-for-branch-regexp (concat "\\(stash@{.*}\\): WIP on " branch)))
    (if (string-match stash-for-branch-regexp stash-list)
        (shell-command (concat "git stash pop " (match-string 1 stash-list))))))

(provide 'gitch)
