;;; init.el --- init -*- lexical-binding: t; -*-
;;; Code:

(setq straight-check-for-modifications '(check-on-save find-when-checking))

;; Nix bin path (guarded so config still works on non-Nix systems)
(let ((nix-bin "/etc/profiles/per-user/vp/bin"))
  (when (file-directory-p nix-bin)
    (add-to-list 'exec-path nix-bin)
    (setenv "PATH" (concat nix-bin ":" (getenv "PATH")))))


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
  ;; HTTPS by default - Emacs daemons often don't inherit SSH_AUTH_SOCK,
  ;; which causes opaque clone failures. Public repos don't need SSH.
  ;; Use a git `insteadOf` rewrite if you want to push over SSH.
  (straight-vc-git-default-protocol 'https)
  :config
  (when (getenv "NIXCONFIG_DIR")
    (let ((nixdir (file-name-as-directory (getenv "NIXCONFIG_DIR"))))
      (setq straight-profiles
            `((base        . ,(file-name-concat nixdir "emacs/straight.lockfile.default.el"))
              (programming . ,(file-name-concat nixdir "emacs/straight.lockfile.programming.el")))))))

;; general provides use-package keywords (:general, :general-config),
;; so it must be loaded before any use-package form that uses them.
(use-package general :demand t)

(use-package kkp
  :straight (:host github :repo "benotn/kkp")
  :config (global-kkp-mode +1))


;;; Mode line -----
(defun vp/mode-line ()
  "Custom mode-line format."
  '(" - "
    (:eval (propertize (buffer-name) 'face 'font-lock-constant-face))
    "%6l:%c (%o) "
    (:eval (when vc-mode
             (concat " | ⇅ " (substring-no-properties vc-mode 5))))
    mode-line-format-right-align
    (:eval (concat "  " (symbol-name major-mode)))
    "  " mode-line-misc-info))


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
  :hook ((prog-mode . display-line-numbers-mode)
         (prog-mode . show-paren-mode))
  :config
  (setq-default truncate-lines t
                display-line-numbers-width 3
                indent-tabs-mode nil
                fill-column 100
                tab-width 4
                mode-line-format (vp/mode-line))

  (auto-save-visited-mode 1)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (xterm-mouse-mode 1)

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
;; Silence cosmetic "nil value is invalid, use 'unspecified" face warnings
;; that the dracula-pro-pro theme emits on theme load and on every new client frame.
(advice-add 'display-warning :around
            (lambda (orig &rest args)
              (let ((msg (cadr args)))
                (unless (and (stringp msg)
                             (string-match-p "nil value is invalid" msg))
                  (apply orig args)))))

(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
(setq frame-background-mode 'dark)
(load-theme 'dracula-pro-pro t)

(defun vp/transparent-background ()
  "Unset the default background in terminal frames for true transparency."
  (unless (display-graphic-p)
    (set-face-background 'default "unspecified-bg" (selected-frame))))

(add-hook 'window-setup-hook            #'vp/transparent-background)
(add-hook 'server-after-make-frame-hook #'vp/transparent-background)


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
  (dolist (pat '("\\`\\*lsp-\.*\\'"
                 "\\`\\*rust-analyzer\.*\\'"))
    (add-to-list 'consult-buffer-filter pat))
  (dolist (buf '("*Async-native-compile-log*"
                 "*straight-process*"
                 "*direnv*"
                 "*Messages*"))
    (add-to-list 'consult-buffer-filter (regexp-quote buf))))

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
  (:keymaps 'dired-mode-map   "?"   #'casual-dired-tmenu)
  (:keymaps 'isearch-mode-map "?"   #'casual-isearch-tmenu)
  (:keymaps 'ibuffer-mode-map "?"   #'casual-ibuffer-tmenu)
  (:keymaps 'Info-mode-map    "?"   #'casual-info-tmenu)
  (:keymaps 'org-mode-map     "C-?" #'casual-org-tmenu))


;;; Org Mode -----
(defun vp/refresh-agenda-files ()
  "Rebuild `org-agenda-files' from `org-directory'."
  (interactive)
  (setq org-agenda-files (directory-files-recursively org-directory "\\.org$")))

(use-package org
  :straight (:host github :repo "bzg/org-mode" :branch "main")
  :hook (org-mode . visual-line-mode)
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
  (org-startup-folded 'content)
  (org-cycle-separator-lines 1)
  (org-hide-emphasis-markers t)
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-tags-column 0)
  (org-fold-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respects-content t)
  (org-clock-persist 'history)
  (org-clock-out-when-done t)
  (org-clock-into-drawer t)
  :config
  (setq org-directory (file-truename "~/org"))
  (vp/refresh-agenda-files)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|" "DONE(d)" "CANCELLED(c)")))

  (setq org-todo-keyword-faces
        '(("NEXT"      . (:foreground "#50fa7b" :weight bold))
          ("WAIT"      . (:foreground "#f1fa8c"))
          ("CANCELLED" . (:foreground "#6272a4" :strike-through t))))

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

  (setq org-refile-targets '((org-agenda-files :maxlevel . 3))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil)

  (org-clock-persistence-insinuate)
  (add-hook 'org-capture-mode-hook #'delete-other-windows))

(general-define-key
 "C-c a" 'org-agenda
 "C-c c" 'org-capture)


;;; Org Extensions -----
(use-package org-modern
  :after org
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :custom
  (org-modern-star 'replace)
  (org-modern-replace-stars "❯")
  (org-modern-list '((?* . "•") (?+ . "›") (?- . "–")))
  (org-modern-checkbox '((?X . "✓") (?\s . "☐") (?- . "–")))
  (org-modern-table-vertical 1)
  (org-modern-table-horizontal 0.2)
  (org-modern-todo-faces
   '(("NEXT"      :foreground "#50fa7b" :weight bold)
     ("WAIT"      :foreground "#f1fa8c")
     ("CANCELLED" :foreground "#6272a4" :strike-through t))))

;; Author recommends :config (not :hook) and a high hook depth so this attaches
;; after org-indent has set up. See https://github.com/jdtsmith/org-modern-indent
(use-package org-modern-indent
  :straight (org-modern-indent :type git :host github :repo "jdtsmith/org-modern-indent")
  :after org
  :config
  (add-hook 'org-mode-hook #'org-modern-indent-mode 90))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autoemphasis t)
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t))


;;; Org Roam -----
(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  :general
  (:prefix "C-c n"
   "f" 'org-roam-node-find
   "i" 'org-roam-node-insert
   "c" 'org-roam-capture)
  :config
  (unless (file-exists-p org-roam-directory)
    (make-directory org-roam-directory t))
  (org-roam-db-autosync-mode)
  ;; Add newly captured roam files to the agenda immediately
  (add-hook 'org-roam-capture-new-node-hook
            (lambda ()
              (when buffer-file-name
                (add-to-list 'org-agenda-files buffer-file-name)))))


;;; Which Key -----
(use-package which-key
  :config
  (which-key-mode)
  (which-key-setup-minibuffer))


;;; Mail (mu4e) -----
(let ((nix-mu4e-file (expand-file-name "nix-mu4e.el" user-emacs-directory)))
  (if (file-exists-p nix-mu4e-file)
      (load nix-mu4e-file nil 'nomessage)
    (warn "nix-mu4e.el not found. Ensure you ran `home-manager switch`.")))

(setq shr-use-colors nil)
(use-package mu4e
  :straight nil                              ; Nix-provided; do not let straight fetch
  :commands (mu4e mu4e-update-mail-and-index)
  :general
  ("C-c m" 'mu4e)
  :custom
  (mu4e-get-mail-command "mbsync -a")
  (mu4e-change-filenames-when-moving t)      ; REQUIRED with mbsync, else UID clashes
  (mu4e-confirm-quit nil)
  (mu4e-sent-messages-behavior 'delete)      ; Proton saves Sent server-side; no 2nd copy
  :config
  ;; Folders are relative to the mu root (~/Mail). Account subdir is `proton`.
  ;; VERIFY exact names with `ls ~/Mail/proton` and adjust if needed.
  (setq mu4e-drafts-folder "/proton/Drafts"
        mu4e-sent-folder   "/proton/Sent"
        mu4e-trash-folder  "/proton/Trash"
        mu4e-refile-folder "/proton/Archive")

  (setq mu4e-maildir-shortcuts
        '((:maildir "/proton/Inbox"   :key ?i)
          (:maildir "/proton/Sent"    :key ?s)
          (:maildir "/proton/Drafts"  :key ?d)
          (:maildir "/proton/Archive" :key ?a)
          (:maildir "/proton/Trash"   :key ?t)))

  ;; Send via msmtp -> Bridge. f-is-evil + --read-envelope-from is the canonical
  ;; msmtp/message-mode pairing; account is picked from the From: header.
  (setq sendmail-program (executable-find "msmtp")
        message-send-mail-function #'message-send-mail-with-sendmail
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-kill-buffer-on-exit t)

  (setq user-mail-address "vp@paulaus.com"
        user-full-name "Vytautas"))
;;; init.el ends here
