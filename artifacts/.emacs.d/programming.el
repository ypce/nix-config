;;; programming.el --- Programming configuration -*- lexical-binding: t; -*-

;;; Commentary:
;;; Programming modes with eglot, treesit, and minimal dependencies

;;; Code:

;;; Tree-sitter (Emacs 29+) -----
(use-package treesit
  :straight nil
  :when (and (fboundp 'treesit-available-p) (treesit-available-p))
  :custom
  (major-mode-remap-alist
   '((python-mode . python-ts-mode)
     (bash-mode . bash-ts-mode)
     (sh-mode . bash-ts-mode)
     (go-mode . go-ts-mode)
     (markdown-mode . markdown-ts-mode)))
  :config
  (setq treesit-language-source-alist
        '((bash "https://github.com/tree-sitter/tree-sitter-bash")
          (go "https://github.com/tree-sitter/tree-sitter-go")
          (gomod "https://github.com/camdencheek/tree-sitter-go-mod")
          (python "https://github.com/tree-sitter/tree-sitter-python")
          (markdown "https://github.com/ikatyang/tree-sitter-markdown")
          (fish "https://github.com/ram02z/tree-sitter-fish"))))

;;; Language Server Protocol (eglot - built-in) -----
(use-package eglot
  :straight nil
  :commands (eglot eglot-ensure)
  :hook ((python-mode python-ts-mode) . eglot-ensure)
  :hook ((go-mode go-ts-mode) . eglot-ensure)
  :hook ((bash-ts-mode sh-mode) . eglot-ensure)
  :hook ((markdown-mode markdown-ts-mode) . eglot-ensure)
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
  (eglot-events-buffer-size 0) ; Disable events buffer for performance
  :config
  (setq read-process-output-max (* 1024 1024)) ; 1MB
  
  ;; Server configurations
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("pylsp")))
  (add-to-list 'eglot-server-programs
               '((go-mode go-ts-mode) . ("gopls")))
  (add-to-list 'eglot-server-programs
               '((bash-ts-mode sh-mode) . ("bash-language-server" "start")))
  (add-to-list 'eglot-server-programs
               '((markdown-mode markdown-ts-mode) . ("marksman"))))

(use-package eldoc
  :straight nil
  :diminish eldoc-mode
  :custom
  (eldoc-echo-area-use-multiline-p nil))


;;; Programming language modes -----

;; Go
(use-package go-mode
  :defer t
  :hook (go-mode . (lambda ()
                     (setq tab-width 4)
                     (setq indent-tabs-mode t))) ; Go uses tabs
  :config
  (when (executable-find "goimports")
    (setq gofmt-command "goimports"))
  (add-hook 'before-save-hook #'gofmt-before-save nil t))

;; Go tree-sitter mode setup
(use-package go-ts-mode
  :straight nil
  :when (and (fboundp 'treesit-available-p) (treesit-available-p))
  :defer t
  :hook (go-ts-mode . (lambda ()
                        (setq tab-width 4)
                        (setq indent-tabs-mode t))))

;; Python (uses built-in python-mode or python-ts-mode)
(use-package python
  :straight nil
  :defer t
  :custom
  (python-indent-offset 4))

;; Markdown
(use-package markdown-mode
  :defer t
  :mode (("\\.md\\'" . markdown-mode)
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
  :diminish diff-hl-mode
  :hook (prog-mode . diff-hl-mode)
  :hook (dired-mode . diff-hl-dired-mode)
  :config
  ;; Integration with magit
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  ;; Live updates without saving (optional, can be slow on large files)
  ;; (diff-hl-flydiff-mode 1)
  )


;;; Utilities -----
(use-package direnv
  :hook (after-init . direnv-mode)
  :custom
  (direnv-always-show-summary nil))

(use-package flycheck
  :hook (prog-mode . flycheck-mode)
  :hook (flycheck-mode . flycheck-set-indication-mode)
  :config
  (setq-default flycheck-indication-mode 'right-margin))

;;; programming.el ends here
