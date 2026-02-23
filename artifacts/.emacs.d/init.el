;; init.el --- init -*- lexical-binding: t; -*-
;;; Code:

;; Only check for modifications when you save files or explicitly
(setq straight-check-for-modifications '(check-on-save find-when-checking))

(add-to-list 'exec-path "/opt/homebrew/bin")
(setenv "PATH" (concat "/opt/homebrew/bin:" (getenv "PATH")))

;; Bootstrap Straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))


;;; Package setup -----
(straight-use-package 'use-package)

(use-package straight
  :custom
  (straight-use-package-by-default t)
  (straight-current-profile 'base)
  (straight-vc-git-default-protocol 'ssh))

(use-package general)

;;; Basic Emacs options -----
(use-package emacs
  :init
  (setq use-short-answers t
        scroll-conservatively 101
        confirm-kill-emacs 'yes-or-no-p
        help-window-select t
        backup-by-copying t
        backup-directory-alist '(("." .,(file-name-concat user-emacs-directory "backup/")))
        create-lockfiles nil
        initial-scratch-message ""
        initial-major-mode 'text-mode
        ring-bell-function 'ignore
        custom-safe-themes t
        initial-buffer-choice t)
  :config
  (setq-default truncate-lines t
                display-line-numbers-width 3
                indent-tabs-mode nil
                fill-column 100
                tab-width 4)

  (auto-save-visited-mode 1)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (xterm-mouse-mode 1)
  ; (fringe-mode '(8 . 8))

  (setq-default mode-line-format '(" - "
                                   (:eval (propertize (buffer-name)) 'face 'font-lock-constant-face)
                                   "%6l:%c (%o) "
                                   (:eval (unless (not vc-mode) (concat " | ⇅ " (substring-no-properties vc-mode 5))))
                                   mode-line-format-right-align
                                   (:eval (concat "  " (symbol-name major-mode)))
                                   "  " mode-line-misc-info))

  :general-config
  ("M-s" 'other-window)
  ("M-u" 'capitalize-word)
  ("C-x C-z" 'nil)
  ("M-=" 'count-words)
  ("M-," 'consult-outline)
  ("<escape>" 'keyboard-escape-quit)

  (:keymaps 'help-mode-map "q" 'kill-buffer-and-window
            "<escape>" 'kill-buffer-and-window))


;;; Clipboard
(use-package clipetty
  :hook (after-init . global-clipetty-mode))


;;; Saving + Recent ---------
(use-package recentf
  :hook (after-init . recentf-mode)
  :custom (recentf-max-saved-items 60))

(use-package savehist :hook (after-init . savehist-mode))

(use-package saveplace
  :config (save-place-mode 1))

;;; Themes + Visuals ---------
(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
(load-theme 'dracula-pro-pro t)
(setq frame-background-mode 'dark)

(use-package diminish)

(use-package centered-cursor-mode
  :commands (centered-cursor-mode)
  :diminish centered-cursor-mode)

(use-package golden-ratio
  :diminish golden-ratio-mode
  :hook (after-init . golden-ratio-mode)
  :config
  (golden-ratio-toggle-widescreen))


;;; Completions -----
(use-package vertico
  :config
  (vertico-mode)
  (vertico-multiform-mode)
  :custom
  (vertico-multiform-commands
   '((execute-extended-command flat)
     (consult-line reverse)
     (consult-recent-file reverse)
     (find-file reverse)))
  (vertico-resize t)
  (vertico-count 15))

(use-package marginalia :config (marginalia-mode))

(use-package orderless :config (setq completion-styles '(orderless basic)))

(use-package consult
  :general
  ("M-b" 'consult-buffer
   "C-s" 'consult-line)
  :config
  (consult-customize consult-buffer :sort t)
  (delq 'consult--source-recent-file consult-buffer-sources)
  (add-to-list 'consult-buffer-filter "\\`\\*lsp-\.*\\'")
  (add-to-list 'consult-buffer-filter "\\`\\*rust-analyzer\.*\\'")
  (let ((buffers '("*Async-native-compile-log*" "*straight-process*" "*direnv*" "*Messages*")))
    (dolist (buf buffers) (add-to-list 'consult-buffer-filter (regexp-quote buf)))))

(use-package corfu
  :config
  (global-corfu-mode)
  (corfu-popupinfo-mode)
  :custom
  (corfu-auto t)
  (corfu-count 8)
  (corfu-auto-prefix 2))

(use-package corfu-terminal :hook (corfu-mode . corfu-terminal-mode))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;;; Programming Modes ------
(let ((straight-current-profile 'programming)
	  (f (expand-file-name "programming.el" user-emacs-directory)))
  (when (file-exists-p f) (load f)))

(use-package emacs
  :hook (prog-mode-hook . display-line-numbers-mode)
  :hook (prog-mode-hook . show-paren-mode))

;;; Dired 
(use-package dired
  :straight nil
  :hook (dired-mode . dired-hide-details-mode)
  :custom
  (dired-listing-switches "-alh --group-directories-first") ; cleaner when details shown
  (dired-kill-when-opening-new-dired-buffer t) ; don't accumulate dired buffers
  :general-config
  (:keymaps 'dired-mode-map
   "(" 'dired-hide-details-mode)) ; toggle with (

;;; Org Mode -----------
(use-package org
  :straight (:host github :repo "bzg/org-mode" :branch "main")
  :general-config
  (:keymaps 'org-mode-map
            :states 'motion
            "<TAB>" 'org-cycle)
  (:keymaps 'org-mode-map :states 'motion :prefix ","
            "c" 'org-copy-visible
            "i" 'org-cite-insert
            "p" 'org-set-property
            "t" 'org-table-create)
  :diminish visual-line-mode
  :hook (org-mode . visual-line-mode)
  :hook (org-mode . (lambda () (diminish 'org-indent-mode)))
  :custom
  (org-ellipsis " ⤵")
  (org-startup-indented t)
  (org-cycle-separator-lines 1)
  (org-hide-emphasis-markers t))

(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-headline-bullets-list '("❯" "❯" "❯" "❯" "❯" "❯" "❯"))
  (org-superstar-item-bullet-alist '((?* . ?-) (?+ . ?›) (?- . ?–)))
  (org-superstar-checkbox-alist '((?X . ?✓) (?\s . ?☐) (?- . ?–)))
  (org-superstar-remove-leading-stars nil)
  (org-superstar-special-todo-items nil))

(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/Notes"))
  :general
  (:prefix "C-c n"
           "f" 'org-roam-node-find
           "i" 'org-roam-node-insert
           "c" 'org-roam-capture)
  :config
  ;; Create the directory (and any parent directories) if it doesn't exist
  (unless (file-exists-p org-roam-directory)
    (make-directory org-roam-directory t))
  
  ;; Start the database sync AFTER making sure the folder exists
  (org-roam-db-autosync-mode))

;;; Keybindings ------
(use-package which-key
  :diminish which-key-mode
  :config
  (which-key-mode)
  (which-key-setup-minibuffer))

;;; Meow - Modal editing (Colemak) ------
(use-package meow
  :demand t
  :config
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-colemak)
  (meow-motion-define-key
  '("e" . meow-prev)
  '("<escape>" . ignore))
  (meow-leader-define-key
  '("?" . meow-cheatsheet)
  '("1" . meow-digit-argument)
  '("2" . meow-digit-argument)
  '("3" . meow-digit-argument)
  '("4" . meow-digit-argument)
  '("5" . meow-digit-argument)
  '("6" . meow-digit-argument)
  '("7" . meow-digit-argument)
  '("8" . meow-digit-argument)
  '("9" . meow-digit-argument)
  '("0" . meow-digit-argument))
  (meow-normal-define-key
  '("0" . meow-expand-0)
  '("1" . meow-expand-1)
  '("2" . meow-expand-2)
  '("3" . meow-expand-3)
  '("4" . meow-expand-4)
  '("5" . meow-expand-5)
  '("6" . meow-expand-6)
  '("7" . meow-expand-7)
  '("8" . meow-expand-8)
  '("9" . meow-expand-9)
  '("-" . negative-argument)
  '(";" . meow-reverse)
  '("," . meow-inner-of-thing)
  '("." . meow-bounds-of-thing)
  '("[" . meow-beginning-of-thing)
  '("]" . meow-end-of-thing)
  '("/" . meow-visit)
  '("a" . meow-append)
  '("A" . meow-open-below)
  '("b" . meow-back-word)
  '("B" . meow-back-symbol)
  '("c" . meow-change)
  '("e" . meow-prev)
  '("E" . meow-prev-expand)
  '("f" . meow-find)
  '("g" . meow-cancel-selection)
  '("G" . meow-grab)
  '("h" . meow-left)
  '("H" . meow-left-expand)
  '("i" . meow-right)
  '("I" . meow-right-expand)
  '("j" . meow-join)
  '("k" . meow-kill)
  '("l" . meow-line)
  '("L" . meow-goto-line)
  '("m" . meow-mark-word)
  '("M" . meow-mark-symbol)
  '("n" . meow-next)
  '("N" . meow-next-expand)
  '("o" . meow-block)
  '("O" . meow-to-block)
  '("p" . meow-yank)
  '("q" . meow-quit)
  '("r" . meow-replace)
  '("s" . meow-insert)
  '("S" . meow-open-above)
  '("t" . meow-till)
  '("u" . meow-undo)
  '("U" . meow-undo-in-selection)
  '("v" . meow-search)
  '("w" . meow-next-word)
  '("W" . meow-next-symbol)
  '("x" . meow-delete)
  '("X" . meow-backward-delete)
  '("y" . meow-save)
  '("z" . meow-pop-selection)
  '("'" . repeat)
  '("<escape>" . ignore))
  (meow-global-mode 1))

;;; init.el ends here
  
