;;; programming.el --- Programming configuration -*- lexical-binding: t; -*-

;;; Commentary:
;;; Programming modes with eglot, treesit, flymake. Minimal deps.

;;; Code:

;;; Tree-sitter (Emacs 29+) -----
(use-package treesit
  :straight nil
  :when (and (fboundp 'treesit-available-p) (treesit-available-p))
  :custom
  (major-mode-remap-alist
   '((python-mode   . python-ts-mode)
     (bash-mode     . bash-ts-mode)
     (sh-mode       . bash-ts-mode)
     (go-mode       . go-ts-mode)
     (markdown-mode . markdown-ts-mode)))
  :config
  (setq treesit-language-source-alist
        '((bash     "https://github.com/tree-sitter/tree-sitter-bash")
          (go       "https://github.com/tree-sitter/tree-sitter-go")
          (gomod    "https://github.com/camdencheek/tree-sitter-go-mod")
          (python   "https://github.com/tree-sitter/tree-sitter-python")
          (markdown "https://github.com/ikatyang/tree-sitter-markdown")
          (fish     "https://github.com/ram02z/tree-sitter-fish"))))


;;; Language Server Protocol (eglot - built-in, drives flymake) -----
(use-package eglot
  :straight nil
  :commands (eglot eglot-ensure)
  :hook ((python-ts-mode
          go-ts-mode
          bash-ts-mode sh-mode
          markdown-mode markdown-ts-mode) . eglot-ensure)
  :general-config
  (:keymaps 'eglot-mode-map
   "C-c C-d" 'eldoc-doc-buffer)
  (:keymaps 'eglot-mode-map :states 'motion :prefix ","
   "f" 'eglot-format-buffer
   "F" 'eglot-format
   "r" 'eglot-reconnect
   "R" 'eglot-rename
   "d" 'eldoc-doc-buffer
   "c" 'xref-find-definitions
   "x" 'eglot-code-actions
   "o" 'eglot-code-action-organize-imports)
  :custom
  (eglot-autoshutdown t)
  (eglot-extend-to-xref t)
  (eglot-events-buffer-size 0) ; perf: don't accumulate event logs
  :config
  (dolist (entry '(((python-ts-mode)            . ("pylsp"))
                   ((go-ts-mode)                . ("gopls"))
                   ((bash-ts-mode sh-mode)      . ("bash-language-server" "start"))
                   ((markdown-mode markdown-ts-mode) . ("marksman"))))
    (add-to-list 'eglot-server-programs entry)))

(use-package eldoc
  :straight nil
  :custom
  (eldoc-echo-area-use-multiline-p nil))


;;; Flymake bindings (used by eglot for diagnostics) -----
(use-package flymake
  :straight nil
  :hook (prog-mode . flymake-mode)
  :general-config
  (:keymaps 'flymake-mode-map :states 'motion :prefix ","
   "n" 'flymake-goto-next-error
   "N" 'flymake-goto-prev-error
   "l" 'flymake-show-buffer-diagnostics))


;;; Language modes -----

;; Go (ts-mode only; major-mode-remap-alist redirects go-mode to it)
(use-package go-ts-mode
  :straight nil
  :when (and (fboundp 'treesit-available-p) (treesit-available-p))
  :defer t
  :hook (go-ts-mode . vp/go-setup)
  :preface
  (defun vp/go-setup ()
    "Per-buffer Go setup: tabs for indent, gofmt on save."
    (setq-local tab-width 4
                indent-tabs-mode t)
    (when (executable-find "goimports")
      (setq gofmt-command "goimports"))
    (add-hook 'before-save-hook #'gofmt-before-save nil t)))

;; Python (built-in)
(use-package python
  :straight nil
  :defer t
  :custom
  (python-indent-offset 4))

;; Markdown
(use-package markdown-mode
  :defer t
  :mode (("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :hook (markdown-mode . visual-line-mode)
  :custom
  (markdown-command "pandoc")
  (markdown-fontify-code-blocks-natively t))

;; Fish shell
(use-package fish-mode
  :defer t
  :mode "\\.fish\\'")

;; Nix
(use-package nix-mode :defer t)


;;; Version Control -----
(use-package diff-hl
  :hook ((prog-mode  . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)))


;;; Utilities -----
(use-package direnv
  :hook (after-init . direnv-mode)
  :custom
  (direnv-always-show-summary nil))

;;; programming.el ends here
