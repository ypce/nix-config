;;; early-init.el --- early init -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil)

;; Big GC during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'after-init-hook
          (lambda ()
            ;; Reasonable defaults for long-running daemon
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

;; Helpful for LSP/subprocess throughput
(setq read-process-output-max (* 1024 1024))

;;; early-init.el ends here

