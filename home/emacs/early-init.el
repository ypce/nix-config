;;; early-init.el --- early init -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil)

;; Big GC during startup, sensible defaults after
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

;; Helpful for LSP/subprocess throughput (applies globally)
(setq read-process-output-max (* 1024 1024))

;; Rounded corners
(add-to-list 'default-frame-alist '(undecorated-round . t))
;;; early-init.el ends here
