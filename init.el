;; -*- lexical-binding: t; -*-
(setq inhibit-startup-message t)
;; (setq warning-minimum-level :error)

(scroll-bar-mode -1) ;; Disable visible scrollbar
(tool-bar-mode -1) ;; Disable the toolbar
(tooltip-mode -1) ;; Disable tooltips
(set-fringe-mode 10) ;; Give some breathing room

(menu-bar-mode -1) ;; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

;; Set Line Numbers but disable for some modes
(column-number-mode)
(setq-default display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)

(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(electric-pair-mode 1) ;; Turns on electric pair mode to more easily wrap selected text in quotes

;; Soft word-wrapping
(global-visual-line-mode 1)
;; Set font
(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 140)

;; Transparency, requires Emacs compiled with GTK (emacs-gtk for X11/emacs-pgtk for wayland)
(set-frame-parameter (selected-frame) 'alpha-background 90)
(add-to-list 'default-frame-alist '(alpha-background . 90))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Load Rose-Pine theme which requires autothemer
(use-package autothemer
  :ensure t
  :defer t)

(add-to-list 'custom-theme-load-path "~/.emacs.d")
(load-theme 'rose-pine t)

;; The ever helpful ivy
(use-package ivy
  :demand t
  :diminish
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^

(global-set-key (kbd "C-M-j") 'counsel-switch-buffer)

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

;; Preview files in dired
(use-package dired-preview
  :ensure t
  :config
  (dired-preview-global-mode 1)
  (setq dired-preview-delay 0.1))

;; Be able to recursively delete folders in dired
(setq dired-recursive-deletes 'top)

;; Use doom modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 30)))

;; rainbow delimiters made checking parantheses easier in lisp
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Generally helpful
(use-package which-key
  :demand t
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3)
  (which-key-mode 1))

(use-package helpful
  :ensure t
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; Managing projects and version control
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Projects")
    (setq projectile-project-search-path '("~/Projects")))
  (setq projectile-switch-project-actions #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-windows-except-diff-v1))

(use-package forge)

;; Orgmode configs
(use-package org
  :config
  (setq org-ellipsis " "))

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/RoamNotes")
  (org-roam-completion-everywhere t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n f" . org-roam-node-find)
	 ("C-c n i" . org-roam-node-insert)
	 :map org-mode-map
	 ("C-M-i" . completion-at-point)
	 :map org-roam-dailies-map
	 ("Y" . org-roam-dailies-capture-yesterday)
	 ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies) ;; Ensure the keymap is available
  (org-roam-db-autosync-mode))

;; LSP stuff
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook
  ((html-mode . lsp-deferred)
   (css-mode . lsp-deferred)
   (json-mode . lsp-deferred))
  :config
  (lsp-enable-which-key-integration t))

(use-package nix-mode
  :ensure t
  :hook (nix-mode . lsp-deferred))

(use-package lua-mode
  :ensure t
  :hook (lua-mode . lsp-deferred))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

;; HTML writing with impatient mode
(use-package simple-httpd
  :ensure t)

(use-package htmlize
  :ensure t)

(use-package impatient-mode
  :ensure t)

;; Code completion
(use-package company
  :ensure t
  :hook (prog-mode . company-mode)
  :config
  (setq company-idle-delay 0.1
	company-minimum-prefix-length 1))

;; Term and the better vterm
(use-package term
  :config
  (setq explicit-shell-file-name "bash")
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"))

(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")
  (setq vterm-max-scrollback 10000)
  :bind ("C-c C-t" . vterm))

;; Elfeed for RSS reader
(use-package elfeed
  :ensure t)

(keymap-global-set "C-x w" #'elfeed)
(setq elfeed-feeds
      '("https://piefed.social/c/perfectdark@lemmy.world/feed"
	"https://veronicaexplains.net/feed"
	"https://マリウス.com/index.xml"
	"https://soatok.blog/feed"
	"https://100r.ca/links/rss.xml"
	"https://www.washingtonpost.com/arcio/rss/category/technology/"
	"https://www.washingtonpost.com/arcio/rss/category/politics/"
	"https://www.washingtonpost.com/arcio/rss/category/business/"
	"https://techcrunch.com/feed/"
	"https://feeds.arstechnica.com/arstechnica/index"
	"http://science.sciencemag.org/rss/current.xml"))
(setq browse-url-browser-function 'eww-browse-url) ;; Opens articles in eww instead of external browser

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("337bc91807652361b31800f1b2a6bbc4d146a8086d85862bb6f280f243a9165c"
     default))
 '(package-selected-packages
   '(all-the-icons autothemer command-log-mode counsel counsel-projectile
		   dired-preview doom-modeline eterm-256color helpful
		   html-ls ivy ivy-rich lsp-mode magit nix-mode
		   org-roam projectile rainbow-delimiters vterm)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
