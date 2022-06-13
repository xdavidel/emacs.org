;;; init.el --- Emacs main configuration file -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

;; Loading eraly-init.el if Emacs version < 27
(unless (featurep 'early-init)
  (load (expand-file-name "early-init" user-emacs-directory-orig)))

(let ((emacs-config-file (concat user-emacs-directory "config.el")))
  (if (file-exists-p emacs-config-file)
      (load-file emacs-config-file)
    (progn
      (require 'org)
      (find-file (concat user-emacs-directory-orig "README.org"))
      (org-babel-tangle)
      (load-file emacs-config-file)
      (byte-compile-file emacs-config-file))))

(provide 'init)
;;; init.el ends here
