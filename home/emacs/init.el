;; init.el --- init -*- lexical-binding: t; -*-
;;; Code:

(setq straight-check-for-modifications '(check-on-save find-when-checking))

(add-to-list 'exec-path "/etc/profiles/per-user/vp/bin")
(setenv "PATH" (concat "/etc/profiles/per-user/vp/bin:" (getenv "PATH")))

;;; Bootstrap Straight.el -----
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
  (straight-vc-git-default-protocol 'ssh)
  :config
  (when (getenv "NIXCONFIG_DIR")
    (let ((nixdir (file-name-as-directory (getenv "NIXCONFIG_DIR"))))
      (setq straight-profiles
            `((base . ,(file-name-concat nixdir "emacs/straight.lockfile.default.el"))
              (programming . ,(file-name-concat nixdir "emacs/straight.lockfile.programming.el")))))))

(use-package general)

(use-package kkp
  :straight (:host github :repo "benotn/kkp")
  :config
  (global-kkp-mode +1))


;;; Basic Emacs options -----
(use-package emacs
  :init
  (setq use-short-answers t
        scroll-conservatively 101
        confirm-kill-emacs 'yes-or-no-p
        help-window-select t
        backup-by-copying t
        backup-directory-alist `(("." . ,(file-name-concat user-emacs-directory "backup/")))
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

  (setq-default mode-line-format
                '(" - "
                  (:eval (propertize (buffer-name) 'face 'font-lock-constant-face))
                  "%6l:%c (%o) "
                  (:eval (unless (not vc-mode)
                           (concat " | ⇅ " (substring-no-properties vc-mode 5))))
                  mode-line-format-right-align
                  (:eval (concat "  " (symbol-name major-mode)))
                  "  " mode-line-misc-info))

  :general-config
  ("M-s" 'other-window)
  ("M-u" 'capitalize-word)
  ("C-x C-z" nil)
  ("M-=" 'count-words)
  ("M-," 'consult-outline)
  ("<escape>" 'keyboard-escape-quit)
  (:keymaps 'help-mode-map
   "q" 'kill-buffer-and-window
   "<escape>" 'kill-buffer-and-window))


;;; Clipboard -----
(use-package clipetty
  :hook (after-init . global-clipetty-mode))


;;; Saving + Recent -----
(use-package recentf
  :hook (after-init . recentf-mode)
  :custom (recentf-max-saved-items 60))

(use-package savehist
  :hook (after-init . savehist-mode))

(use-package saveplace
  :config (save-place-mode 1))


;;; Themes + Visuals -----
(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
(load-theme 'dracula-pro-pro t)
(setq frame-background-mode 'dark)

(defun vp/transparent-background ()
  (unless (display-graphic-p)
    (set-face-background 'default "unspecified-bg" (selected-frame))))

(add-hook 'window-setup-hook #'vp/transparent-background)
(add-hook 'server-after-make-frame-hook #'vp/transparent-background)

(use-package diminish)

(use-package centered-cursor-mode
  :commands (centered-cursor-mode)
  :diminish centered-cursor-mode)

(use-package golden-ratio
  :diminish golden-ratio-mode
  :hook (after-init . golden-ratio-mode)
  :config (golden-ratio-toggle-widescreen))


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

(use-package marginalia
  :config (marginalia-mode))

(use-package orderless
  :config (setq completion-styles '(orderless basic)))

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
    (dolist (buf buffers)
      (add-to-list 'consult-buffer-filter (regexp-quote buf)))))

(use-package corfu
  :config
  (global-corfu-mode)
  (corfu-popupinfo-mode)
  :custom
  (corfu-auto t)
  (corfu-count 8)
  (corfu-auto-prefix 2))

(use-package corfu-terminal
  :hook (corfu-mode . corfu-terminal-mode))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))


;;; Programming Modes -----
(let ((straight-current-profile 'programming)
      (f (expand-file-name "programming.el" user-emacs-directory)))
  (when (file-exists-p f) (load f)))

(use-package emacs
  :hook (prog-mode . display-line-numbers-mode)
  :hook (prog-mode . show-paren-mode))


;;; Dired -----
(use-package dired
  :straight nil
  :hook (dired-mode . dired-hide-details-mode)
  :custom
  (dired-listing-switches "-alh --group-directories-first")
  (dired-kill-when-opening-new-dired-buffer t)
  :general-config
  (:keymaps 'dired-mode-map
   "(" 'dired-hide-details-mode))

(use-package casual
  :straight (:host github :repo "kickingvegas/casual"
             :files ("lisp/*.el"))
  :after dired
  :general-config
  (:keymaps 'dired-mode-map   "?" #'casual-dired-tmenu)
  (:keymaps 'isearch-mode-map "?" #'casual-isearch-tmenu)
  (:keymaps 'ibuffer-mode-map "?" #'casual-ibuffer-tmenu)
  (:keymaps 'Info-mode-map    "?" #'casual-info-tmenu)
  (:keymaps 'org-mode-map     "C-?" #'casual-org-tmenu))


;;; Org Mode -----
(use-package org
  :straight (:host github :repo "bzg/org-mode" :branch "main")
  :hook (org-mode . visual-line-mode)
  :hook (org-mode . (lambda () (diminish 'org-indent-mode)))
  :diminish visual-line-mode
  :general-config
  (:keymaps 'org-mode-map :states 'motion
   "<TAB>" 'org-cycle)
  (:keymaps 'org-mode-map :states 'motion :prefix ","
   "c" 'org-copy-visible
   "i" 'org-cite-insert
   "p" 'org-set-property
   "t" 'org-table-create)
  :custom
  (org-ellipsis " ⤵")
  (org-startup-indented t)
  (org-cycle-separator-lines 1)
  (org-hide-emphasis-markers t)
  :config
  ;; Single directory for everything
  (setq org-directory (file-truename "~/Notes"))

  (setq org-agenda-files
        (directory-files-recursively "~/Notes" "\\.org$"))

  ;; TODO states
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|" "DONE(d)" "CANCELLED(c)")))

  (setq org-todo-keyword-faces
        '(("NEXT"      . (:foreground "#50fa7b" :weight bold))
          ("WAIT"      . (:foreground "#f1fa8c"))
          ("CANCELLED" . (:foreground "#6272a4" :strike-through t))))

  ;; Capture templates
  (setq org-capture-templates
        `(("i" "Inbox" entry
           (file ,(expand-file-name "inbox.org" org-directory))
           "* TODO %?\n/Captured/ %U\n")

          ("m" "Meeting" entry
           (file+headline ,(expand-file-name "agenda.org" org-directory) "Meetings")
           ,(concat "* %? :meeting:\n"
                    "<%<%Y-%m-%d %a %H:00>>\n\n"
                    "** Attendees\n\n"
                    "** Notes\n\n"
                    "** Actions\n"))

          ("e" "Event" entry
           (file+headline ,(expand-file-name "agenda.org" org-directory) "Events")
           "* %?\n<%<%Y-%m-%d %a %H:00>>")))

  ;; Refile into any open org file, up to 3 levels deep
  (setq org-refile-targets
        '((org-agenda-files :maxlevel . 3)))
  (setq org-refile-use-outline-path 'file)
  (setq org-outline-path-complete-in-steps nil)

  (add-hook 'org-capture-mode-hook #'delete-other-windows))

(general-define-key
 "C-c a" 'org-agenda
 "C-c c" 'org-capture)

;;; Org Superstar -----
(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-headline-bullets-list '("❯" "❯" "❯" "❯" "❯" "❯" "❯"))
  (org-superstar-item-bullet-alist '((?* . ?-) (?+ . ?›) (?- . ?–)))
  (org-superstar-checkbox-alist '((?X . ?✓) (?\s . ?☐) (?- . ?–)))
  (org-superstar-remove-leading-stars nil)
  (org-superstar-special-todo-items nil))


;;; Org Roam -----
(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/Notes"))
  :general
  (:prefix "C-c n"
   "f" 'org-roam-node-find
   "i" 'org-roam-node-insert
   "c" 'org-roam-capture)
  :config
  (unless (file-exists-p org-roam-directory)
    (make-directory org-roam-directory t))
  (org-roam-db-autosync-mode)
  ;; New roam files are added to agenda immediately on creation
  (add-hook 'org-roam-capture-new-node-hook
            (lambda ()
              (when buffer-file-name
                (add-to-list 'org-agenda-files buffer-file-name)))))


;;; Which Key -----
(use-package which-key
  :diminish which-key-mode
  :config
  (which-key-mode)
  (which-key-setup-minibuffer))

;;; Meow - Modal editing (Colemak) -----
;; (use-package meow ...)

;;; init.el ends here
