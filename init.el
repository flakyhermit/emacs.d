; Emacs init file
;; Jewel James

;; DO NOT EDIT THIS BLOCK ---------------------------
;; Bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Use straight.el to install all listed packages
;; To add a new package, add it to the list in package-list.el
(load-file (expand-file-name "package-list.el" user-emacs-directory))
(mapc (lambda(package-name)
	(straight-use-package package-name)) package-list)
;; END OF BLOCK -------------------------------------

;; Change garbage collection threshold for faster loading
(setq gc-cons-threshold 100000000
      gc-cons-percentage 0.6)
;; Disabling some stuff during startup
(defvar file-name-handler-alist--save file-name-handler-alist)
(setq file-name-handler-alist nil)

(setq frame-inhibit-implied-resize t)
;; Basic configurations
(add-to-list 'load-path "~/.emacs.d/custom/mental-health-log")
(require 'mental-health-log)

;; Load the theme
(load-theme 'doom-sourcerer t)
(doom-themes-org-config)

;; Setup alternate directory for backups
(setq backup-directory-alist `(("." . "~/.saves")))

;; Inhibit the splash screen and message
(setq inhibit-startup-message t)
(setq initial-scratch-message (concat ";; \n;; Emacs loaded in " (emacs-init-time) "\n;; -----------------------------------\n;; Howdy Jewel! Welcome to Emacs.\n;; Today is " (format-time-string "%d %B, %A")  "\n"))

;; (setq initial-major-mode 'fundamental-mode)

;; Set default frame size
(add-to-list 'default-frame-alist '(height . 36))
(add-to-list 'default-frame-alist '(width . 130))

;; Better scrolling experience
(setq scroll-margin 0
      scroll-conservatively 101 ; > 100
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

;; Disable all GUI crap
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)

;; (desktop-save-mode +1)
(global-undo-tree-mode +1)

;; After-init hook
(add-hook 'after-init-hook (lambda()
			     (global-visual-line-mode +1)
			     (column-number-mode +1)
			     (beacon-mode +1)
			     (winner-mode +1)
			     (global-company-mode +1)))

;; Set custom face settings
(add-to-list 'default-frame-alist '(font . "Iosevka-12"))
(set-face-attribute 'variable-pitch nil :font "Iosevka-12")
(set-face-attribute 'fixed-pitch nil :inherit 'default)

;; Global keybindings
(global-set-key (kbd "C-x C-t") 'eshell)
(global-set-key (kbd "C-x k") 'kill-this-buffer)
(global-set-key (kbd "C-(") 'evil-prev-buffer)
(global-set-key (kbd "C-)") 'evil-next-buffer)
(global-set-key (kbd "C-x d") (lambda() (interactive) (dired ".")))
(global-set-key (kbd "C-x C-d") 'dired)
(global-set-key (kbd "C-c d") 'sdcv-search-pointer+)

;; Buffer switching
(global-set-key (kbd "C-x b") #'switch-to-next-buffer)
(global-set-key (kbd "C-x B") #'switch-to-prev-buffer)
(global-set-key (kbd "C-x C-b") #'switch-to-buffer)

;; Custom functions
;; Window management
(defvar window-state 'maximized)
(defun window-minimize ()
  (enlarge-window -15)
  (setq window-state 'minimized))
(defun window-maximize ()
  (enlarge-window 15)
  (setq window-state 'maximized))
(defun window-state-toggle ()
  (interactive)
  (if (eq window-state 'maximized)
      (window-minimize)
    (window-maximize)))
(global-set-key (kbd "C-x ^") #'window-state-toggle)
;; Window geometry modes ----
(defun set-frame-geometry (width height)
  (set-frame-width (nth 0 (frame-list)) width)
  (set-frame-height (nth 0 (frame-list)) height))

(defun my-set-frame-mode ()
  (interactive)
  (setq modes '(default notepad docked))
  (setplist 'default '(str "Default (1)" width 130 height 50))
  (setplist 'notepad '(str "Notepad (2)" width 60 height 30))
  (setplist 'docked '(str "Docked (3)" width 70 height 60))
  (setq assocl '(("Default (1)" . default)
		 ("Notepad (2)" . notepad)
		 ("Docked (3)" . docked)))
  (setq strlist '())
  (setq mode (cdr (assoc (completing-read "Modes: " (dolist (elt modes strlist)
					  (add-to-list 'strlist (get elt 'str)))) assocl)))
  (set-frame-geometry (get mode 'width) (get mode 'height))
  (hide-mode-line-mode -1)
  (unless (not (eq mode 'notepad))
    (hide-mode-line-mode 1)))
(global-set-key (kbd "C-x 5 g") 'my-set-frame-mode)

(defun my-set-frame-notepad ()
  (interactive)
  (set-frame-geometry 50 30))
(defun my-set-frame-default ()
  (interactive)
  (set-frame-geometry 120 36))

(defun xah-next-user-buffer ()
  (interactive)
  (next-buffer)
  (let ((i 0))
    (while (< i 20)
      (if (not (xah-user-buffer-q))
          (progn (next-buffer)
                 (setq i (1+ i)))
        (progn (setq i 100))))))

(defun xah-previous-user-buffer ()
  (interactive)
  (previous-buffer)
  (let ((i 0))
    (while (< i 20)
      (if (not (xah-user-buffer-q))
          (progn (previous-buffer)
                 (setq i (1+ i)))
        (progn (setq i 100))))))
;; (global-set-key (kbd "<f11>") 'xah-previous-user-buffer)
;; (global-set-key (kbd "<f12>") 'xah-next-user-buffer)

;; Custom function definitions
(defun xm/editing-mode(state)
  (interactive)
  (variable-pitch-mode state)
  (setq-local line-spacing 2)
  (setq-local left-margin-width 2)
  (setq-local right-margin-width 2))

(add-hook 'prog-mode-hook (lambda ()
			    (display-line-numbers-mode 1)
			    (hl-line-mode 1)
			    (hl-todo-mode 1)))
(add-hook 'conf-mode-hook (lambda()
			    (display-line-numbers-mode 1)
			    (hl-line-mode 1)
			    (hl-todo-mode 1)))
(add-hook 'text-mode-hook (lambda ()
			    (xm/editing-mode 1)
			    (flyspell-mode 1)
			    (display-line-numbers-mode -1)))
(add-hook 'org-mode-hook (lambda ()
			    (xm/editing-mode 1)))
;; Custom extensions
(add-to-list 'load-path "~/.emacs.d/custom")
(require 'personal-journal)

;; recentf ------------------------
(setq recentf-max-saved-items 100)
(recentf-mode t)

;; evil ---------------------------
(setq evil-want-C-u-scroll t
      evil-undo-system 'undo-tree
      evil-want-keybinding nil)
(evil-mode +1)
;; (define-key evil-normal-state-map (kbd "g s") 'save-buffer)
(define-key evil-normal-state-map (kbd "g b") 'switch-to-buffer)
(defun xm/save-and-kill-this-buffer ()
  "Save the current buffer and then kill it; Same as Vim's ':wq'"
  (interactive)
  (save-buffer)
  (kill-this-buffer))
(with-eval-after-load 'evil-maps ; avoid conflict with company tooltip selection
  (define-key evil-insert-state-map (kbd "C-n") nil)
  (define-key evil-insert-state-map (kbd "C-p") nil))
(with-eval-after-load 'evil
  (evil-ex-define-cmd "q" #'kill-this-buffer)
  (evil-ex-define-cmd "wq" #'xm/save-and-kill-this-buffer))

;; evil-surround ------------------
(evil-surround-mode 1)
(define-key evil-normal-state-map (kbd "g s") 'evil-surround-region)

;; evil-collection- ---------------
(evil-collection-init)

;; evil-snipe ---------------------
;; (setq evil-snipe-scope 'buffer)
;; (evil-snipe-mode 1)

;; crux ---------------------------
(define-key ctl-x-map (kbd "C-_") 'crux-delete-file-and-buffer)
(define-key global-map (kbd "<f9>") 'crux-visit-term-buffer)
(define-key global-map (kbd "<f9>") 'crux-visit-term-buffer)

(defvar completion-frontend 'ido) ;; ivy, helm, ido

(when (eq completion-frontend 'ido)
  ;; ido ----------------------------
  (setq ido-everywhere t
	ido-enable-flex-matching t)
  (defun bind-ido-keys ()
    "Keybindings for ido mode."
    (define-key ido-completion-map (kbd "C-j") 'ido-next-match) 
    (define-key ido-completion-map (kbd "C-k") 'ido-prev-match))
  (add-hook 'ido-setup-hook #'bind-ido-keys)
  (ido-mode +1)
  (define-key ctl-x-map (kbd "C-r") 'crux-recentf-find-file)
  (ido-ubiquitous-mode +1)
  ;; (flx-ido-mode +1)
  ;; (ido-yes-or-no-mode +1)
  )

(when (eq completion-frontend 'ivy)
  ;; ivy ----------------------------
  (setq ivy-height 13
	ivy-wrap t)
  ;; (define-key ivy-mode-map (kbd "C-j") 'ivy-next-line) 
  ;; (define-key ivy-mode-map (kbd "C-k") 'ivy-previous-line)
  (add-hook 'ivy-mode-hook #'ivy-rich-mode)
  (ivy-mode 1)
  ;; counsel ------------------------
  (define-key ctl-x-map (kbd "C-b") 'persp-switch-to-buffer)
  (define-key ctl-x-map (kbd "C-f") 'counsel-find-file)
  (define-key ctl-x-map (kbd "C-r") 'counsel-recentf)
  (define-key mode-specific-map (kbd "C-f") 'counsel-find-file)
  (counsel-mode +1))

;; helm ---------------------------
(when (eq completion-frontend 'helm)
  (define-key mode-specific-map (kbd "x r") #'helm-org-rifle-agenda-files)
  (define-key mode-specific-map (kbd "x b") #'helm-org-rifle-current-buffer)
  (setq helm-display-buffer-height 10)
  (define-key ctl-x-map (kbd "b") 'helm-buffers-list)
  (define-key ctl-x-map (kbd "C-f") 'helm-find-files)
  (define-key ctl-x-map (kbd "C-r") 'helm-recentf)
  (helm-mode 1))
(global-set-key (kbd "C-h i") #'helm-info)

;; amx ----------------------------
(setq amx-backend 'auto)
(amx-mode 1)

;; show-paren-mode ----------------
(setq show-paren-delay 0)
(show-paren-mode +1)

;; avy ----------------------------
(define-key global-map (kbd "C-;") 'avy-goto-word-or-subword-1)
(define-key global-map (kbd "C-:") 'avy-goto-char)
;; (avy-setup-default)

;; ace-window ---------------------
(global-set-key (kbd "C-x o") 'ace-window)

;; dired --------------------------
(setq dired-du-size-format t)
(with-eval-after-load 'dired
  (add-hook 'dired-mode-hook #'dired-hide-details-mode)
  (add-hook 'dired-mode-hook #'dired-hide-dotfiles-mode)
  (define-key dired-mode-map "-" 'dired-up-directory))

;; projectile ---------------------
(setq projectile-completion-system completion-frontend
      projectile-mode-line-function '(lambda () (format " [%s]" (projectile-project-name))))
(projectile-mode 1)
(define-key global-map (kbd "C-x p p") 'projectile-switch-project)
(define-key global-map (kbd "C-x p f") 'projectile-find-file)
(define-key global-map (kbd "C-x p n") 'projectile-add-known-project)
(define-key global-map (kbd "C-x p r") 'projectile-recentf)

;; powerline ----------------------
;; (powerline-center-theme)
;; (spaceline-spacemacs-theme)
(spaceline-helm-mode 1)
 
;; persp-mode ---------------------
(setq persp-nil-name "-")
;; (persp-mode 0)

;; magit --------------------------
(define-key ctl-x-map (kbd "g") 'magit-status)

;; olivetti -----------------------
(setq olivetti-body-width 120)
(define-key ctl-x-map (kbd "t o") 'olivetti-mode)
(add-hook 'olivetti-mode-hook 'hide-mode-line-mode)

;; pdf-tools ----------------------
(pdf-tools-install)

;; markdown-mode ------------------
(setq wc-modeline-format "%tw")
(with-eval-after-load 'markdown-mode
  (add-hook 'markdown-mode-hook 'wc-mode)
  (add-hook 'markdown-mode-hook 'mixed-pitch-mode))

;; mixed-pitch-mode ---------------
(with-eval-after-load 'mixed-pitch
  (diminish 'mixed-pitch-mode)
  (add-to-list 'mixed-pitch-fixed-pitch-faces 'org-tag)
  (add-to-list 'mixed-pitch-fixed-pitch-faces 'outline-1)
  (add-to-list 'mixed-pitch-fixed-pitch-faces 'outline-2)
  (add-to-list 'mixed-pitch-fixed-pitch-faces 'org-list-dt)
  (add-to-list 'mixed-pitch-fixed-pitch-faces 'org-done))

;; helpful-mode
(global-set-key (kbd "C-h v") 'helpful-variable)
(global-set-key (kbd "C-h f") 'helpful-function)
(global-set-key (kbd "C-h o") 'helpful-symbol)
(global-set-key (kbd "C-h k") 'helpful-key)

;; bongo -------------------------
(setq bongo-default-directory "~/Media/Music/")

;; yas ---------------------------
(with-eval-after-load 'yasnippet
  (setq yas-snippet-dirs '("/home/monk/.emacs.d/snippets"))
  (message "%s" yas-snippet-dirs)
  (yas-reload-all))
(require 'warnings)
(add-to-list 'warning-suppress-types '(yasnippet backquote-change))

(defun xs/isodate-file-name(filename)
  (concat filename "-" (format-time-string "%Y-%m-%d") ".org"))

;; org ----------------------------
(setq org-directory "~/Dropbox/Notes/org"
      org-return-follows-link t
      org-todo-keywords '((sequence "TODO(t)" "ACTV(a!)" "REFL(r)" "|" "HOLD(h)" "DONE(d)"))
      org-inbox-file "~/Dropbox/Notes/org/inbox.org"
      org-agenda-files '("~/Dropbox/Notes/org")
      org-refile-targets '((org-inbox-file :maxlevel . 2)
			   ("~/Dropbox/Notes/org/emacs.org" :maxlevel . 1)
			   ("~/Dropbox/Notes/org/todo.org" :maxlevel . 2)
			   ("~/Dropbox/Notes/org/lists/books.org" :maxlevel . 3))
      org-archive-location (concat org-directory "/archive/%s_archive::")
      org-startup-with-inline-images t
    ;; org-indent-indentation-per-level 1
    ;; org-adapt-indentation nil
      org-hide-emphasis-markers t
      org-capture-templates
      `(("t" "Add a TODO" entry
	(file ,(concat org-directory "/todo.org")) 
	"* TODO %?\n")
	("T" "Just a THOUGHT" entry
	(file ,(concat org-directory "/inbox.org"))
	"* %?\n")
	("Q" "A QUOTE" entry
	(file ,(concat org-directory "/quotes.org"))
	"* %?\n\n")
	("b" "Add a BLOG post IDEA" entry
	(file ,(concat org-directory "/blog-post-ideas.org")) 
	"* %?\n")
	("B" "Add a BOOK to the 'considering' list" entry
	(file+olp ,(concat org-directory "/lists/books.org") "Considering")
	"* <book%?\n")
	("k" "Add a BOOK to read with Krys" entry
	(file+olp ,(concat org-directory "/lists/books.org") "Shelved" "Fiction")
	"* <book%? :krys:\n")
	("r" "Add an ARTICLE to read later" checkitem
	(file+olp+datetree ,(concat org-directory "/lists/read-later.org"))
	"- [ ] %:annotation %?\n")
	("v" "Add a word to the vocabulary list" plain
	(file+headline ,(concat org-directory "/vocabulary.org") ,(format-time-string "%F"))
	"<voc%?\n")
	("e" "An Emacs customization idea" entry
	(file+headline ,(concat org-directory "/emacs.org") "To-do")
	"* TODO %? \n\n")))
(define-key mode-specific-map (kbd "a") 'org-agenda)
(define-key mode-specific-map (kbd "c") 'org-capture)
;; (define-key mode-specific-map (kbd "c") 'counsel-org-capture)
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-q") 'counsel-org-tag)
  (add-hook 'org-mode-hook 'org-indent-mode)
  (add-hook 'org-mode-hook 'yas-minor-mode)
  ;; (add-hook 'org-mode-hook 'org-superstar-mode)
  (add-hook 'org-mode-hook 'mixed-pitch-mode)
  (add-hook 'org-capture-mode-hook #'org-align-all-tags)
  (add-hook 'org-capture-mode-hook #'yas-expand))

;; org-superstar  --------------------
;; (setq org-superstar-headline-bullets-list '(9702))

;; org-journal --------------------
(setq org-journal-dir (concat org-directory "/journal")
      org-journal-file-type 'monthly
      org-journal-date-format "%A, %d %B %Y"
      org-journal-prefix-key (kbd "C-c j"))
(global-set-key (kbd "C-c j n") 'org-journal-new-entry)
(global-set-key (kbd "C-c j s") 'org-journal-search-forever)
(global-set-key (kbd "C-c j o") 'org-journal-open-current-journal-file)

;; anki-editor --------------------
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c x a") 'anki-editor-insert-note)
  (define-key org-mode-map (kbd "C-c x p") 'anki-editor-push-notes))
(setq anki-editor-create-decks t 
      anki-editor-org-tags-as-anki-tags t)
;; (add-hook 'org-mode-hook #'anki-editor-mode)

;; deft ---------------------------
(setq deft-directory org-directory
      deft-recursive t
      deft-auto-save-interval -1.0
      deft-extensions '("org")
      deft-default-extension "org")
(define-key global-map (kbd "<f8>") 'deft)
(define-key mode-specific-map (kbd "f") 'deft-find-file)
;; (add-hook 'deft-mode-hook #'custom/editing-mode)

;; org-ref ------------------------
(require 'org-ref)
(setq org-ref-completion-library 'org-ref-ivy-cite)
(setq org-ref-bibliography-notes (concat org-directory "/references.org"))
(setq org-ref-notes-directory (concat org-directory "/knowledgebas/references"))
(setq reftex-default-bibliography '("~/Dropbox/Notes/org/bibliography/references.bib"))
(setq bibtex-completion-bibliography "~/Dropbox/Notes/org/bibliography/references.bib")
(setq org-ref-default-bibliography '("~/Dropbox/Notes/org/bibliography/references.bib")
      org-ref-pdf-directory "~/Dropbox/Notes/org/knowledgebase/references/documents/")
(with-eval-after-load 'org-ref
  (org-ref-ivy-cite-completion))

;; org-roam -----------------------
(setq org-roam-directory (concat org-directory "/knowledgebase")
      org-roam-capture-templates `(("d" "default"
				    plain #'org-roam-capture--get-point
				    "\n- References :: \n- Tags :: %?\n\n"
				    :file-name "%<%Y%m%d%H%M%S>-${slug}"
				    :head "#+title: ${title}\n#+created: %U\n"
				    :unnarrowed t)))
(define-key mode-specific-map (kbd "n l") 'org-roam-buffer-toggle-display)
(define-key mode-specific-map (kbd "n F") 'org-roam-find-file)
(define-key mode-specific-map (kbd "n r") 'org-roam-find-ref)
(define-key mode-specific-map (kbd "n g") 'org-roam-show-graph)
(define-key mode-specific-map (kbd "n i") 'org-roam-insert)
(add-hook 'org-roam-mode-hook #'org-roam-bibtex-mode)
(org-roam-mode +1)

;; company ------------------------
(with-eval-after-load 'company
  (setq company-idle-delay 1)
  (push 'company-web-html company-backends))

;; org-roam-bibtex ----------------
(with-eval-after-load 'org-roam-bibtex
  (add-to-list 'orb-preformat-keywords "abstract"))
(setq orb-templates
  '(("r" "ref" plain (function org-roam-capture--get-point) ""
     :file-name "references/${citekey}"
     :head "#+title: ${title}\n#+roam_key: ${ref}\n#+roam_tags: ref\n#+created: %U\n" ; <--
     :unnarrowed t)))
(define-key mode-specific-map (kbd "n a") 'orb-note-actions)
(define-key mode-specific-map (kbd "n f") 'orb-find-non-ref-file)

;; diminish------------------------
(setq diminished-modes
      '(beacon-mode org-roam-mode org-indent-mode ivy-mode counsel-mode evil-snipe-mode flyspell-mode undo-tree-mode org-roam-bibtex-mode company-mode mixed-pitch-mode visual-line-mode evil-snipe-local-mode buffer-face-mode))
(add-hook 'emacs-startup-hook (lambda() (mapc (lambda(minor-mode) (diminish minor-mode)) diminished-modes)))

(load "./my-faces.el")

;; Reset garbage-collection threshold
(add-hook 'emacs-startup-hook (lambda()
				(setq gc-cons-threshold 16777216
				      gc-cons-percentage 0.1)
				(setq file-name-handler-alist file-name-handler-alist--save)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files
   '("~/Dropbox/Notes/org/lists/books.org" "/home/monk/Dropbox/Notes/org/watch.org" "/home/monk/Dropbox/Notes/org/archlinux.org" "/home/monk/Dropbox/Notes/org/blog-post-ideas.org" "/home/monk/Dropbox/Notes/org/contacts.org" "/home/monk/Dropbox/Notes/org/cv.org" "/home/monk/Dropbox/Notes/org/devices.org" "/home/monk/Dropbox/Notes/org/emacs-article.org" "/home/monk/Dropbox/Notes/org/emacs.org" "/home/monk/Dropbox/Notes/org/events.org" "/home/monk/Dropbox/Notes/org/finances.org" "/home/monk/Dropbox/Notes/org/higher-studies.org" "/home/monk/Dropbox/Notes/org/hindi.org" "/home/monk/Dropbox/Notes/org/idioms.org" "/home/monk/Dropbox/Notes/org/inbox.org" "/home/monk/Dropbox/Notes/org/key-issues.org" "/home/monk/Dropbox/Notes/org/kindle-support.org" "/home/monk/Dropbox/Notes/org/listen.org" "/home/monk/Dropbox/Notes/org/long-term-goals.org" "/home/monk/Dropbox/Notes/org/minecraft.org" "/home/monk/Dropbox/Notes/org/observations.org" "/home/monk/Dropbox/Notes/org/podcasts.org" "/home/monk/Dropbox/Notes/org/purchases.org" "/home/monk/Dropbox/Notes/org/quotes.org" "/home/monk/Dropbox/Notes/org/self-improvement.org" "/home/monk/Dropbox/Notes/org/thoughts.org" "/home/monk/Dropbox/Notes/org/todo.org" "/home/monk/Dropbox/Notes/org/typing-test.org" "/home/monk/Dropbox/Notes/org/vocabulary.org"))
 '(safe-local-variable-values '((org-log-into-drawer . t) (org-log-done . time))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
