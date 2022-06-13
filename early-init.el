;;; early-init.el --- early configurations -*- lexical-binding: t -*-
;;;
;;; Commentary:
;;; Emacs early init file
;;; This file is executed before any graphics (Emacs Version > 27)
;;;
;;; Code:

;; Increase the GC threshold for faster startup
;; The default is 800 kilobytes.  Measured in bytes.
(let ((old-gc-treshold gc-cons-threshold))
  (setq gc-cons-threshold most-positive-fixnum)
  (add-hook 'after-init-hook
            (lambda () (setq gc-cons-threshold old-gc-treshold))))

;; Never use old code!
(customize-set-variable 'load-prefer-newer t)

(defvar user-emacs-directory-orig user-emacs-directory
  "Points to the original `user-emacs-directory' before any changes.")

(defvar user-emacs-tmp-dir (expand-file-name (format "emacs%d" (user-uid)) temporary-file-directory)
  "A directory to save Emacs temporary files.")

;; Change emacs user directory to keep the real one clean
(setq user-emacs-directory (let* ((cache-dir-xdg (getenv "XDG_CACHE_HOME"))
                                  (cache-dir (if cache-dir-xdg (concat cache-dir-xdg "/emacs/")
                                               (expand-file-name "~/.cache/emacs/"))))
                             (mkdir cache-dir t)
                             cache-dir))

(setenv "EMACS_CONFIG_DIR" user-emacs-directory)

;; Native compilation settings
(when (featurep 'native-compile)
  ;; Silence compiler warnings as they can be pretty disruptive
  (setq native-comp-async-report-warnings-errors nil)

  ;; Make native compilation happens asynchronously
  (setq native-comp-deferred-compilation t)

  ;; Set the right directory to store the native compilation cache
  (when (fboundp 'startup-redirect-eln-cache)
    (if (version< emacs-version "29")
        (add-to-list 'native-comp-eln-load-path (convert-standard-filename (expand-file-name "var/eln-cache/" user-emacs-directory)))
      (startup-redirect-eln-cache (convert-standard-filename (expand-file-name "var/eln-cache/" user-emacs-directory))))))

;; Disable package.el initialization at startup
(setq package-enable-at-startup nil
      package-quickstart nil)
(advice-add 'package--ensure-init-file :override 'ignore)

;; prevent glimpse of UI been disabled
(setq-default
 default-frame-alist
 '((horizontal-scroll-bars . nil)   ;; No horizontal scroll-bars
   (vertical-scroll-bars . nil)     ;; No vertical scroll-bars
   (menu-bar-lines . 0)             ;; No menu bar
   (right-divider-width . 1)        ;; Thin vertical window divider
   (right-fringe . 8)               ;; Thin right fringe
   (tool-bar-lines . 0)))           ;; No tool bar
(setq inhibit-startup-message t)

;; inhibit resizing frame
(setq frame-inhibit-implied-resize t)

;; Set transparent background
(let ((custom-fram-transparency '(95 . 95)))
  (set-frame-parameter (selected-frame) 'alpha custom-fram-transparency)
  (add-to-list 'default-frame-alist `(alpha . ,custom-fram-transparency)))

;; Profile Emacs startup speed as well as performence tweaks
(let ((old-file-name-handler-alist file-name-handler-alist)
      (old-modline-format mode-line-format))
  (setq file-name-handler-alist nil
        mode-line-format nil) ;; prevent flash of unstyled modeline at startup
  (add-hook 'emacs-startup-hook
            (lambda () (setq file-name-handler-alist old-file-name-handler-alist
                             mode-line-format old-modline-format)
              (message "Emacs loaded in %s with %d garbage collections."
                           (emacs-init-time)
                           gcs-done))))

;; Compile warnings
(setq comp-async-report-warnings-errors nil) ;; native-comp warning
(setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))

(provide 'early-init)
;;; early-init.el ends here
