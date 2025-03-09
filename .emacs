;; -*- lexical-binding: t -*-

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

(setq straight-use-package-by-default t
      package-enable-at-startup nil)

(use-package emacs
  :straight nil
  :custom
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  :init
  ;(load-theme 'deeper-blue)
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)
  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  :config
  (global-display-line-numbers-mode t)
  (global-visual-line-mode 1)
  (global-auto-revert-mode 1)
  ;; revert buffers when the underlying file has changed
  (setq inhibit-startup-message t
	visible-bell t
	gc-cons-threshold (* 10 1024 1024)
	display-line-numbers-type 'relative
	history-length 25
	use-dialog-box nil
	global-auto-revert-non-file-buffers t)
  (set-face-attribute 'default nil :height 140)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (set-fringe-mode 1)
  (menu-bar-mode -1)
  (display-time-mode t)
  (recentf-mode 1)
  (savehist-mode 1)
  (save-place-mode 1)
  (add-to-list 'default-frame-alist '(fullscreen . fullscreen))
  :bind
  (("C-x v" . (lambda (&optional n) (interactive "p") (enlarge-window (- (or n 1)))))))

(use-package zenburn-theme
  :config
  (load-theme 'zenburn t))

(use-package toxi-theme
  :straight (toxi-theme
	     :type git
	     :host github
	     :repo "postspectacular/toxi-theme"))

(use-package frame
  :straight nil
  :bind ("C-c t" . toggle-transparency)
  :config
  (defun toggle-transparency ()
    (interactive)
    (let ((alpha (frame-parameter nil 'alpha-background)))
      (set-frame-parameter nil 'alpha-background (if (eq alpha 40) 100 40))
      (redraw-frame (selected-frame)))))

(use-package files
  :straight nil
  :config
  (setq make-backup-files nil
        vc-follow-symlinks t
        backup-directory-alist `((".*" . ,(expand-file-name "backups/" user-emacs-directory)))
        auto-save-file-name-transforms (list (list ".*" (expand-file-name "auto-saves/" user-emacs-directory) t)))
  (global-auto-revert-mode t)  ;; Enable global auto-revert mode
  (make-directory (expand-file-name "backups/" user-emacs-directory) t)
  (make-directory (expand-file-name "auto-saves/" user-emacs-directory) t))

(use-package cus-edit
  :straight nil
  :config
  (setq custom-file "~/.config/emacs/emacs-custom.el")
  (load custom-file t))

(use-package sh-mode
  :straight nil
  :mode (".bashrc" . sh-mode))

(use-package treesit
  :straight nil
  :config
  (setq treesit-font-lock-level 4))

(use-package savehist
  :straight nil
  :init
  (savehist-mode))

(use-package python
  :straight nil
  :hook ((python-mode . (lambda ()
			  (make-local-variable 'python-shell-virtualenv-root)))
	 (inferior-python-mode . (lambda ()
				   (setq-local completion-at-point-functions '(t))))))

(use-package dired
  :straight (:type built-in)
  :hook (dired-mode . dired-omit-mode)
  :custom
  (dired-listing-switches "-alh")
  (dired-dwim-target t)
  (dired-mouse-drag-files t))

(use-package dired-x
  :straight (:type built-in)
  :after dired
  :config
  (setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
  )

(use-package paredit
  :config
  (add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode))

(use-package quarto-mode)

(use-package company
  :config
  (global-company-mode t))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion--category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :bind (:map minibuffer-local-map
	      ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(use-package vertico
  :init
  (vertico-mode))

(use-package rainbow-identifiers)

(use-package epkg
  :hook (epkg-list-mode . (lambda () (setq truncate-lines t)))
  :bind (:map epkg-list-mode-map
              ("j" . next-line)
              ("k" . previous-line)
              ("u" . beginning-of-buffer)
              ("b" . my-goto-penultimate-line)
              ("q" . kill-buffer-and-window)))

(use-package markdown-mode)

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package vterm)

(use-package julia-repl
  :config
  (add-to-list 'vterm-eval-cmds '("julia-repl--show")))

(use-package julia-mode
  :mode "\\.jl\\'"
  :hook
  (julia-mode . lsp-mode))

(use-package julia-snail
  :custom
  (julia-snail-terminal-type :vterm)
  :config
  (add-hook 'julia-mode-hook #'julia-snail-mode))

(use-package julia-ts-mode
  :mode "\\.jl$")
  
(use-package lsp-julia
  :config
  (setq lsp-julia-default-environment "/home/kevinsilberberg/.julia/environments/v1.11")
  (require 'lsp-julia))

(add-to-list 'lsp-language-id-configuration '(julia-ts-mode . "julia"))
(lsp-register-client
(make-lsp-client :new-connection (lsp-stdio-connection 'lsp-julia--rls-command)
                 :major-modes '(julia-mode ess-julia-mode julia-ts-mode)
                 :server-id 'julia-ls
                 :multi-root t))

(use-package yasnippet
  :init
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  :config
  (setq yas-triggers-in-field t)
  (yas-global-mode 1)
  (add-hook 'after-save-hook
	    (lambda ()
	      (when (string-prefix-p (expand-file-name "~/.emacs.d/snippets")
				     (or buffer-file-name ""))
		(yas-reload-all))))
  )

; use pyvenv-create then do venv-workon
(use-package pyvenv
  :config)

(use-package atomic-chrome
  :config
  (atomic-chrome-start-server)
  (setq atomic-chrome-default-major-mode 'markdown-mode)
)


; whitespace handling
(defun set-up-whitespace-handling ()
  (interactive)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

;;; whitespace handling to modes
(add-hook 'julia-mode-hook 'set-up-whitespace-handling)
(add-hook 'emacs-lisp-mode 'set-up-whitespace-handling)
(add-hook 'lua-mode-hook 'set-up-whitespace-handling)
(add-hook 'poly-quarto-mode-hook 'set-up-whitespace-handling)
(add-hook 'markdown-mode-hook 'set-up-whitespace-handling)
(add-hook 'python-mode-hook 'set-up-whitespace-handling)
(add-hook 'c-mode-hook 'set-up-whitespace-handling)
(add-hook 'yaml-mode-hook 'set-up-whitespace-handling)
