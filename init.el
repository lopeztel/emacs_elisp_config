;;Custom Variables
;; You will most likely need to adjust this font size for your system!
(defvar efs/default-font-size 140)
(defvar efs/default-variable-font-size 140)

;; Make frame transparency overridable
(defvar efs/frame-transparency '(90 . 90))

;; Don't show the splash screen
(setq inhibit-startup-message t
      visible-bell t)  ; Comment at end of line!

;; Turn off some unneeded UI elements
(menu-bar-mode -1)  ; Leave this one on if you're a beginner!
(tool-bar-mode -1)
(scroll-bar-mode -1)
(set-fringe-mode 10)

;; Reload buffers when the underlying file has changed
(global-auto-revert-mode 1)
;; Revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)

;; Display line numbers in every buffer
(global-display-line-numbers-mode 1)
;;Display line relative line numbers
(setq display-line-numbers-type 'relative)

;; Recently edited files
(recentf-mode t)

;; Save what you enter into minibuffer prompts
(setq history-length 25)
(savehist-mode 1)

;; Remember and restore the last cursor location of opened files
(save-place-mode 1)

;;-------------------------------------Transparent frames----------------------------------

;; Set frame transparency for X11
;; (set-frame-parameter (selected-frame) 'alpha efs/frame-transparency)
;; (add-to-list 'default-frame-alist `(alpha . ,efs/frame-transparency))
;; (set-frame-parameter (selected-frame) 'fullscreen 'maximized)
;; (add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Set frame transparency for Wayland
(set-frame-parameter nil 'alpha-background 85)
(add-to-list 'default-frame-alist `(alpha-background . 85))

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
		term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; -------------------------------------Font------------------------------------------------
(set-face-attribute 'default nil :font "FiraCode Nerd Font Mono" :height efs/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "FiraCode Nerd Font Mono" :height efs/default-font-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "FiraCode Nerd Font Mono" :height efs/default-variable-font-size :weight 'regular)

;;(add-to-list 'default-frame-alist
;;             '(font . "FiraCode Nerd Font Mono-14"))

;; -------------------------------------startup performance------------------------------------------------
;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

;; -------------------------------------Package System setup------------------------------------------------
;; Package System setup
(require 'package)

;; Initialize package sources
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("org" . "https://orgmode.org/elpa/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;------------------------------------Keybindings------------------------------------------
;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package general
  :after evil
  :config
  (setq evil-undo-system 'undo-redo)
  (general-create-definer efs/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (efs/leader-keys
    "t" '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")
    "f" '(:ignore t :which-key "files")
    "ff" 'counsel-find-file
    "fr" 'counsel-recentf
    "b" '(:ignore t :which-key "buffers")
    "bs" 'ivy-switch-buffer
    "bd" 'evil-delete-buffer
    "bb" '(lambda () (interactive) (switch-to-buffer nil)) ; to previous buffer
    "w" '(:ignore t :which-key "windows")
    "wd" 'delete-window
    "wo" 'delete-other-windows
    "w1" 'split-window-vertically
    "w2" 'split-window-horizontally
    "o" '(:ignore t :which-key "org")
    "oa" 'org-agenda
    "oc" 'org-capture
    "op" 'org-present
    "fs" '(lambda () (interactive) (find-file (expand-file-name "~/.emacs.d/init.el")))))

(general-create-definer my-local-leader-def
  :prefix "SPC m")

(my-local-leader-def 'normal go-mode-map
  "ta" 'go-tag-add
  "td" 'go-tag-remove
  "tg" 'go-gen-test-dwim
  )

;; -------------------------------------Evil mode (Vim like keybindings)------------------------------------------------
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;;(setq evil-undo-system 'undo-redo)

;; -------------------------------------Theming------------------------------------------------
(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  ;(doom-themes-neotree-config)
  ;; or for treemacs users
  ;(setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  ;(doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config)
  (load-theme 'doom-nord t))


(use-package all-the-icons
  :ensure t)
;;The first time you load your configuration on a new machine, you’ll
;;need to run `M-x all-the-icons-install-fonts` so that mode line
;;icons display correctly.

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)
	   (doom-modeline-modal 1)
	   (doom-modeline-modal-icon 1)))


;; -------------------------------------Which-key------------------------------------------------
(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

;;--------------------------------------Selection menus------------------------------------------

(use-package ivy
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

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  ;; Uncomment the following line to have sorting remembered across sessions!
  ;(prescient-persist-mode 1)
  (ivy-prescient-mode 1))

;;--------------------------------------Help menus------------------------------------------

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;;--------------------------------------Text scaling------------------------------------------

(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(efs/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))

;;-------------------------------------Orgmode------------------------------------------------

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "FiraCode Nerd Font Mono" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :ensure org-contrib
  :pin gnu
  :commands (org-capture org-agenda)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (setq org-image-actual-width nil)
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'note)
  (setq org-log-into-drawer t)
  (setq org-return-follows-link t)

  (setq org-agenda-files
        '("~/org/Todos.org"
          "~/org/work/Todos.org"
          "~/org/Agenda.org"
          "~/org/Birthdays.org"
	  "~/org/Holidays.org"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
    '((sequence "TODO(t)" "|" "DONE(d@/!)")
      (sequence "OPEN(o)" "IN PROGRESS(i)" "REOPENED(r)" "|""RESOLVED(s@/!)" "CLOSED(c@/!)" "WON'T DO(w@/!)")))

  
  (setq org-refile-targets
    '(("~/org/archive/Agenda-archive.org" :maxlevel . 2)
      ("~/org/archive/Todos-archive.org" :maxlevel . 2)
      ("~/org/archive/work/Work-todos-archive.org" :maxlevel . 2)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("personal" . ?p)
       ("work" . ?w)
       ("exercise" . ?e)
       ("note" . ?n)
       ("TOC" . ?T)))
  
  (efs/org-font-setup))

;; Nicer bullets
(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;;Center org buffers

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

;; Modern org
;;(use-package org-modern
;;    :hook (org-mode . org-modern-mode))
;;(global-org-modern-mode)

;; Capture templates
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/org/work/Todos.org" "Captured todos")
         "* TODO %?\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree "~/org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")))

(setq org-src-preserve-indentation t)
(use-package org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))

;; Autogeneration of Table Of Contents
(if (require 'toc-org nil t)
    (progn
      (add-hook 'org-mode-hook 'toc-org-mode)

      ;; enable in markdown, too
      (add-hook 'markdown-mode-hook 'toc-org-mode)
      (define-key markdown-mode-map (kbd "\C-c\C-o") 'toc-org-markdown-follow-thing-at-point))
(warn "toc-org not found"))
    

;;------------------------------------------------org-modern---------------------------------------------------
;; Add frame borders and window dividers
; (modify-all-frames-parameters
;  '((right-divider-width . 40)
;    (internal-border-width . 40)))
; (dolist (face '(window-divider
;                 window-divider-first-pixel
;                 window-divider-last-pixel))
;   (face-spec-reset-face face)
;   (set-face-foreground face (face-attribute 'default :background)))
; (set-face-background 'fringe (face-attribute 'default :background))
;
; (setq
;  ;; Edit settings
;  org-auto-align-tags nil
;  org-tags-column 0
;  org-catch-invisible-edits 'show-and-error
;  org-special-ctrl-a/e t
;  org-insert-heading-respect-content t
;
;  ;; Org styling, hide markup etc.
;  org-hide-emphasis-markers t
;  org-pretty-entities t
;  org-ellipsis "…"
;
;  ;; Agenda styling
;  org-agenda-tags-column 0
;  org-agenda-block-separator ?─
;  org-agenda-time-grid
;  '((daily today require-timed)
;    (800 1000 1200 1400 1600 1800 2000)
;    " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
;  org-agenda-current-time-string
;  "◀── now ─────────────────────────────────────────────────")
;;------------------------------------------------markdown-mode------------------------------------------------
(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

;;-------------------------------------------pdflatex publishing-----------------------------------------------------
;; Taken from: https://www.aidanscannell.com/post/org-mode-resume/ for the resume thing
  ;; Import ox-latex to get org-latex-classes and other funcitonality
  ;; for exporting to LaTeX from org
  (require 'ox-latex)
    ;;:init
    ;; code here will run immediately
    ;;:config
    ;; code here will run after the package is loaded
    (setq org-latex-pdf-process
          '("pdflatex -interaction nonstopmode -output-directory %o %f"
            "bibtex %b"
            "pdflatex -interaction nonstopmode -output-directory %o %f"
            "pdflatex -interaction nonstopmode -output-directory %o %f"))
    (setq org-latex-with-hyperref nil) ;; stop org adding hypersetup{author..} to latex export
    ;; (setq org-latex-prefer-user-labels t)

    ;; deleted unwanted file extensions after latexMK
    (setq org-latex-logfiles-extensions
          (quote ("lof" "lot" "tex~" "aux" "idx" "log" "out" "toc" "nav" "snm" "vrb" "dvi" "fdb_latexmk" "blg" "brf" "fls" "entoc" "ps" "spl" "bbl" "xmpi" "run.xml" "bcf" "acn" "acr" "alg" "glg" "gls" "ist")))

    (unless (boundp 'org-latex-classes)
      (setq org-latex-classes nil))

(require 'ox-extra)
(ox-extras-activate '(latex-header-blocks ignore-headlines))

;; Code formatting export from org mode (using some packages)
;;(setq org-latex-listings 'minted
;;      org-latex-packages-alist '(("" "minted"))
;;      org-latex-packages-alist '(("" "svg"))
;;      org-latex-packages-alist '(("" "color"))
;;      org-latex-pdf-process
;;      '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
;;        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
;;        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))

;;--------------------------------------------html publishing-----------------------------------------------------

;; proper html publishing of all files, taken from: https://orgmode.org/worg/org-tutorials/org-publish-html-tutorial.html 
(require 'ox-publish)
(setq org-publish-use-timestamps-flag nil) ;;don't generate only when files change
(setq org-publish-project-alist
'(("org-work-files"
   :base-directory "~/org/work/"
   :base-extension "org"
   :publishing-directory "~/work-dashboard/"
   :recursive t
   :publishing-function org-html-publish-to-html
   :headline-levels 4
   :auto-preamble t
  )
  ("org-presentation-files"
   :base-directory "~/org/work/Presentations/"
   :base-extension "org"
   :publishing-directory "~/work-dashboard/Presentations/"
   :recursive t
   :publishing-function org-html-publish-to-html
   :headline-levels 4
   :auto-preamble t
  )
  ("org-work-assets"
   :base-directory "~/org/work/media/"
   :base-extension "jpg\\|png\\|gif\\|pdf\\|svg\\|diff"
   :publishing-directory "~/work-dashboard/media/"
   :recursive t
   :publishing-function org-publish-attachment
  )
  ("org-presentation-assets"
   :base-directory "~/org/work/Presentations/media/"
   :base-extension "jpg\\|png\\|gif\\|pdf\\|svg\\|diff"
   :publishing-directory "~/work-dashboard/Presentations/media/"
   :recursive t
   :publishing-function org-publish-attachment
  )
  ("work-dashboard" :components("org-work-files" "org-work-assets" "org-presentation-files" "org-presentation-assets"))))

;; live viewing
(use-package simple-httpd)

;; fixing face inheriting
;; Fix broken face inheritance
(let ((faces (face-list)))
  (dolist (face faces)
    (let ((inh (face-attribute face :inherit)))
      (when (not (memq inh faces))
        (set-face-attribute face nil :inherit nil)))))

;;(use-package htmlize)

;;-------------------------------------Org presentations--------------------------------------------

(use-package org-present)

(use-package ox-reveal)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-safe-remote-resources
   '("\\`https://fniessen\\.github\\.io/org-html-themes/org/theme-readtheorg\\.setup\\'"))
 '(package-selected-packages
   '(toc-org org-present visual-fill-column org-bullets doom-modeline all-the-icons evil-collection use-package which-key-posframe org-jira evil doom-themes)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
