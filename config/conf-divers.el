;;; configuration générale

(eval-when-compile
  (require 'cl))

                    ;;;;;;;;;;;;;;;
                    ;;; BUFFERS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; astuces ;;;
;; C-x C-s : sauver le buffer courant                                         ;;
;; C-x s : sauve tous les buffers (y : oui, n : non, !: tous sans demander)   ;;
;;       - C-r : visualiser le tampon en demande de sauvregarde               ;;
;;             - (M C-c pour sortir)                                          ;;
;; M-x rename-buffer : renommer le tampon (sans renommer le fichier !)        ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ibuffer ;;;
(require 'ibuffer)
(setq ibuffer-saved-filter-groups
      (quote (("default"
               ("ERC"   (mode . erc-mode))
               ("LaTeX" (mode . latex-mode))
               ("Mail"
                (or  ;; mail-related buffers
                 (mode . message-mode)
                 (mode . mail-mode)))
               ("Org" ;; all org-related buffers
                (mode . org-mode))
               ("C" (mode . c-mode))
               ("Lisp" (or
                        (mode . emacs-lisp-mode)
                        (mode . lisp-mode)))
               ("Perl" (mode . cperl-mode))
               ("XML" (mode . nxml-mode))
               ("Dired" (mode . dired-mode))
               ))))

(add-hook 'ibuffer-mode-hook
          (lambda ()
            (ibuffer-switch-to-saved-filter-groups "default")))
(global-set-key (kbd "C-x C-b") 'ibuffer)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


                    ;;;;;;;;;;;;;;;
                    ;;;  DIRED  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; dired
(require 'dired-x)
(require 'dired+)
;; toujours réutiliser le buffer courant :
;; (toggle-dired-find-file-reuse-dir t)
;; permet de copier un fichier d'un buffer dired vers
;; un autre buffer dired
(setq dired-dwim-target t)
;; (dé)compression automatique des fichiers lus et écrits
(auto-compression-mode t)
;;; dired
;; pourvoir supprimer des dossiers récursivement
(setq dired-recursive-deletes t)

(when (eq system-type 'cygwin)
  (require 'w32-find-dired))

(require 'run-assoc)

(when (eq system-type 'cygwin)
  (setq associated-program-alist
      '(("/cygdrive/c/Program Files/SumatraPDF/SumatraPDF.exe" "\\.pdf$")
        ((lambda (file)
           (browse-url
	    (concat "file:///" (expand-file-name file)))) "\\.html?$"))))

;;; ouvrire dans dired avec xdg-open
(when (eq system-type 'gnu/linux)
  (defun dired-do-shell-launch-file-default ()
    (interactive)
    (save-window-excursion
      (dired-do-async-shell-command
       "$HOME/.emacs.d/public/bin/open.sh" current-prefix-arg ;; linux;; multiple files
       ;; "nohup xdg-open" current-prefix-arg ;; linux can open multiple files, but one at a time
       ;; "see" current-prefix-arg ;; linux;; can open at most 1 file (being opened)
       ;; "open" current-prefix-arg ;; mac os x
       (dired-get-marked-files t current-prefix-arg)))))
(when (eq system-type 'gnu/linux)
  (define-key dired-mode-map (kbd "s-o") 'dired-do-shell-launch-file-default))

;; cacher les infos détaillées
(require 'dired-details)
(require 'dired-details+)
(dired-details-install)

;; unmount disk in dired
;;http://loopkid.net/articles/2008/06/27/force-unmount-on-mac-os-x
(when (eq system-type 'gnu/linux)
  (defun dired-do-shell-unmount-device ()
    (interactive)
    (save-window-excursion
      (dired-do-async-shell-command
       "umount" current-prefix-arg ;; linux
       ;; "diskutil unmount" current-prefix-arg ;; mac os x
       (dired-get-marked-files t current-prefix-arg)))))
(when (eq system-type 'gnu/linux)
  (define-key dired-mode-map (kbd "s-u") 'dired-do-shell-unmount-device))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


                    ;;;;;;;;;;;;;;;;;
                    ;;;  EDITION  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; line-move-visual permet de passer d'une ligne à l'autre même
;;; en mode "logical line"
(setq line-move-visual nil)

;;; visual-line-mode : c'est un mode "visual line" (=/= logical line)
;; (setq global-visual-line-mode t) ;; global
(add-hook 'text-mode-hook 'turn-on-visual-line-mode)
(add-hook 'fundamental-mode-hook 'turn-on-visual-line-mode)
(add-hook 'xbbcode-mode-hook 'turn-on-visual-line-mode)
(add-hook 'bbcode-mode-hook 'turn-on-visual-line-mode)
(add-hook 'markdown-mode-hook 'turn-on-visual-line-mode)

;;; Afficher la 'parenthèse correspondante'
(show-paren-mode 1)
(setq show-paren-delay 0)

;;; surligner la région marquée
(transient-mark-mode 0)

;;; entrer une touche supprime la sélection (active transient-mark-mode)
(delete-selection-mode 1)

;;; input method
(global-set-key (kbd "C-x C-m i") 'set-input-method)

;;; codage des caractères
;; utf-8 par défaut
;; (setq current-language-environment "French")
;; (setq default-input-method "french-keyboard")
;; (setq keyboard-coding-system (quote utf-8))
;; (set-terminal-coding-system 'utf-8)
;; (set-keyboard-coding-system 'utf-8)
;; (set-language-environment 'french)
(prefer-coding-system 'utf-8)

;; régler les fin de lignes
(defun unix-file ()
  "Change the current buffer to Latin 1 with Unix line-ends."
  (interactive)
  (set-buffer-file-coding-system 'utf-8-unix t))

(defun dos-file ()
  "Change the current buffer to Latin 1 with DOS line-ends."
  (interactive)
  (set-buffer-file-coding-system 'utf-8-dos t))

(defun mac-file ()
  "Change the current buffer to Latin 1 with Mac line-ends."
  (interactive)
  (set-buffer-file-coding-system 'utf-8-mac t))

;;;en mode "complete" il fournit un grand nombre de complétions
(setq tab-always-indent 'complete)

;;; delim
;; Kill text between two delimiters, preserving structure.
(require 'delim-kill)

(setq-default show-trailing-whitespace t)
(setq default-indicate-empty-lines t)

;;; unfill paragraph
(defun jbb-unfill-paragraph ()
  "Does the opposite of fill-paragraph"
  (interactive)
  (let
      ((fill-column (point-max)))
    (fill-paragraph nil)))

;;; undo tree
(require 'undo-tree)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




                    ;;;;;;;;;;;;;;;;;;;
                    ;;;  INTERFACE  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; activer la roulette
;;(mouse-wheel-mode t)

;;; numéro de colonne :
(column-number-mode t)


;; inhiber l'écran de démarrage
(setq inhibit-startup-message t)

;;; Menus etc...
(tool-bar-mode 0)
(scroll-bar-mode t)
(set-scroll-bar-mode 'right)
(menu-bar-mode 1)
(blink-cursor-mode 1)


;;; police
;; manuel :
(when (eq system-type 'windows-nt)
  (set-face-attribute 'default nil :family "Courier New" :height 120))
(when (eq system-type 'gnu/linux)
  (set-face-attribute 'default nil :family "Liberation Mono" :height 120)
  ;; (set-face-attribute 'default nil :family "DejaVu Sans Mono" :height 100)
  ;; (set-face-attribute 'default nil :family "Droid Sans Mono" :height 120)
  ;; (set-face-attribute 'default nil :family "Anonymous Pro" :height 120)
  ;; (set-face-attribute 'default nil :family "Inconsolata" :height 120)
  )
;;(set-face-attribute 'default nil :family "Consolas" :height 100)
;;(set-face-attribute 'default nil :family "Courier" :height 100)

;;; theme
;; désactiver : M-x disable-theme
;; (load-theme 'pastels-on-dark t)
(add-to-list 'custom-theme-load-path "~/.emacs.d/public/lisp/elpa/tango-2-theme-20120312/")
(add-to-list 'custom-theme-load-path "~/.emacs.d/public/lisp/elpa/solarized-theme-20120613/")
;;(load-theme 'tango-2 t)
(load-theme 'solarized-dark t)
;; (load-theme 'ujelly t)
;; (load-theme 'underwater t)
;; (load-theme 'zen-and-art t)

;; démarrer maximisé
(when (eq system-type 'windows-nt)
  (defun maximize-frame ()
    "Maximizes the active frame in Windows"
    (interactive)
    ;; Send a `WM_SYSCOMMAND' message to the active frame with the
    ;; `SC_MAXIMIZE' parameter.
    (when (eq system-type 'windows-nt)
      (w32-send-sys-command 61488)))
  (add-hook 'window-setup-hook 'maximize-frame t))

;;; barre de titre
(setq frame-title-format "GNU/Emacs -- %b")


;;; popup
(require 'popup)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;;;;;;;;;;;;;;;;;
                    ;;; mode-line ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; diminish.el ;;;
;; alléger la mode-line pour les mode mineurs                                ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (require 'diminish nil 'noerror)
  (eval-after-load "company"
    '(diminish 'company-mode "Cmp"))
  (eval-after-load "abbrev"
    '(diminish 'abbrev-mode "Abbr"))
  (eval-after-load "yasnippet"
    '(diminish 'yas/minor-mode "Yas")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; alléger la mode-line pour les mode majeurs                                ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'emacs-lisp-mode-hook
  (lambda()
    (setq mode-name "Elisp")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; afficher l'heure
(display-time)

;; change la demande de confirmation de "yes or no" en "y or n"
(fset 'yes-or-no-p 'y-or-n-p)

;;; activation de icicles
;;(require 'icicles)
;;(icy-mode 1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


                    ;;;;;;;;;;;;;;;;;
                    ;;;  WINDOWS  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; switch-window de Dim permet de passer d'une fenêtre à une autre
;;; avec C-x o grâce à un numéro.
;; (require 'switch-window-autoloads)

;;; window number permet de changer de window avec M-WINDOW_NUMBER
(require 'window-number)
(window-number-mode)
(window-number-meta-mode)

;;; Special Windows :

;;; *compilation*
(setq special-display-buffer-names
      `(("*compilation*" . ((name . "*compilation*")
                            ,@default-frame-alist
                            (left . (- 1))
                            (top . 0)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;;;;;;;;;;;;;;;;;;;;;;;
                    ;;;  DICTIONNAIRES  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun lookup-wikipedia ()
  "Look up the word under cursor in Wikipedia.
This command generates a url for Wikipedia.com and switches you
to browser. If a region is active (a phrase), lookup that phrase."
  (interactive)
  (let (myword myurl)
    (setq myword
          (if (and transient-mark-mode mark-active)
              (buffer-substring-no-properties (region-beginning) (region-end))
            (thing-at-point 'symbol)))
    (setq myword (replace-regexp-in-string " " "_" myword))
    (setq myurl (concat "http://en.wikipedia.org/wiki/" myword))
    (browse-url myurl)
    ))

;;; text-translator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; keys ;;;
;; C-u F6 : sélection du dictionnaire par défaut                              ;;
;; F6 : traduit le mot avec le dictionnaire par défaut                        ;;
;; F7 : traduit le ou les mots sélectionnés avec le dictionnaire de son choix ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'text-translator)
(global-set-key (kbd "<f6>") 'text-translator)
(global-set-key (kbd "<f7>") 'text-translator-all)

;; The trasnlation results show the popup (text overlay).
;; You have to require the popup.el. (http://github.com/m2ym/auto-complete)
(require 'popup)
(setq text-translator-display-popup t)

;;; ispell
;; dictionnaire en français
(when (eq system-type 'windows-nt)
  (setq ispell-program-name "c:/Program Files/Aspell/bin/aspell.exe"))
(when (eq system-type 'cygwin)
  (setq ispell-program-name "/cygdrive/c/Program Files/Aspell/bin/aspell.exe"))
(when (eq system-type 'gnu/linux)
  (setq ispell-program-name "/usr/bin/aspell"))
(setq ispell-extra-args '("--sug-mode=ultra"))
(setq ispell-dictionary "francais")
;; liste de dictionnaire
(require 'ispell)
;; brezhoneg :
(add-to-list 'ispell-dictionary-alist
             '("brezhoneg"
               "[A-Za-zùñéèêàçœæÉÈÀÇŒÆÊ]"
               "[^A-Za-zùñéèêàçœæÉÈÀÇŒÆÊ]"
               "[']" t ("-C" "-d" "brezhoneg") "~latin1" iso-8859-1))
;; ajouter au menu
(require 'easymenu)

(defun my-ispell-brezhoneg-dictionary () ;;;;;; BREZHONEG
  "Switch to the brezhoneg dictionary."
  (interactive)
  (ispell-change-dictionary "brezhoneg"))
(easy-menu-add-item  nil '("tools" "spell")
                     ["Select brezhoneg Dict" my-ispell-brezhoneg-dictionary t])

(defun my-ispell-francais-dictionary () ;;;;;;; FRANCAIS
  "Switch to the francais dictionary."
  (interactive)
  (ispell-change-dictionary "francais"))
(easy-menu-add-item  nil '("tools" "spell")
                     ["Select francais Dict" my-ispell-francais-dictionary t])

(defun my-ispell-english-dictionary () ;;;;;;; ENGLISH
  "Switch to the english dictionary."
  (interactive)
  (ispell-change-dictionary "english"))
(easy-menu-add-item  nil '("tools" "spell")
                     ["Select english Dict" my-ispell-english-dictionary t])

;;; FLYSPELL
;; pour des raisons de performance :
(setq flyspell-issue-message-flag 'nil)
;; activer pour les modes suivants :
(dolist (hook '(text-mode-hook org-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
;; desactiver pour les modes suivants :
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))
;; activer dans les commentaires uniquement :
(add-hook 'c++-mode-hook (lambda () (flyspell-prog-mode)))
(add-hook 'cperl-mode-hook (lambda () (flyspell-prog-mode)))
(add-hook 'lisp-mode-hook (lambda () (flyspell-prog-mode)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


                    ;;;;;;;;;;;;;;;
                    ;;;  TRAMP  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (when (eq system-type 'cygwin)
;;   (setq ange-ftp-ftp-program-name "/usr/bin/lftp.exe"))
(setq tramp-default-method "ssh")
;; (nconc (cadr (assq 'tramp-login-args (assoc "ssh" tramp-methods)))
;;        '(("bash" "-i")))
;; (setcdr (assq 'tramp-remote-sh (assoc "ssh" tramp-methods))
;; 	'("bash -i"))
;; windows
;;(setq tramp-default-method "plink")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


                    ;;;;;;;;;;;;;;;;;;
                    ;;;  LECTEURS  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; configuration de docview afin de visualiser pdf, ps etc.
(when (eq system-type 'cygwin)
  (setq doc-view-ghostscript-program "/usr/bin/gs.exe"))
(when (eq system-type 'gnu/linux)
  (setq doc-view-ghostscript-program "/usr/bin/gs"))
;;(setq doc-view-dvipdf-program "")
;;(setq doc-view-pdftotext-program "")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


                    ;;;;;;;;;;;;;;;
                    ;;;  CEDET  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(load "/home/jbbourgoin/.emacs.d/public/lisp/cedet-1.0/common/cedet.el")

(require 'ede)
;(require 'semantic)
(require 'eieio)
(require 'sr-speedbar)
(global-ede-mode t)                      ; Enable the Project management system
;(setq semantic-load-turn-everything-on t)
;(require 'semantic-load)
;(semantic-load-enable-code-helpers)      ; Enable prototype help and smart completion 
;(setq semanticdb-default-save-directory "~/.emacs.d/semantic-cache/")
;;(global-srecode-minor-mode 1)            ; Enable template insertion menu
;; speedbar
;; sr-speedbar : la barre dans un buffer plutôt que dans une fenêtre
(global-set-key (kbd "C-x p") 'sr-speedbar-toggle)
(setq sr-speedbar-width-x '80)
(setq sr-speedbar-auto-refresh nil)
(setq sr-speedbar-right-side nil)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


                    ;;;;;;;;;;;;;;;;;;;;;
                    ;;;  NAVIGATEURS  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (eq system-type 'cygwin)
  (progn
    ;; WINDOWS :
    ;;(setq browse-url-browser-function 'browse-url-generic
    ;;      browse-url-generic-program
    ;;"c:/Users/jbbourgoin/AppData/Local/Google/Chrome/Application/chrome.exe")
    (setq browse-url-browser-function 'browse-url-generic
          browse-url-generic-program
          "c:/Program Files/Mozilla Firefox/firefox.exe")))

(when (eq system-type 'gnu/linux)
  (progn
    (setq browse-url-browser-function 'browse-url-generic
          browse-url-generic-program "firefox")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


                    ;;;;;;;;;;;;;;;;;;;;;
                    ;;;  NAVIGATEURS  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (eq system-type 'windows-nt)
  (defun magit-escape-for-shell (str)
    (if (or (string= str "git")
        (string-match "^--" str))
          str
        (concat "'" (replace-regexp-in-string "'" "'\\''" str) "'"))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


                    ;;;;;;;;;;;;;;
                    ;;;  MAIL  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; mail user agent
(setq mail-user-agent 'gnus-user-agent)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;;;;;;;;;;;;;;;;;;;;
                    ;;;  IMPRESSION  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; impression post-script :
(setq ps-paper-type 'a4
      ps-font-family 'Courier
      ps-print-size 10
      ps-print-header t
      ps-landscape-mode nil)
(setq-default ps-header-lines 1)
(setq ps-print-color-p 'black-white)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


                    ;;;;;;;;;;;;;;;;;;;
                    ;;;  YASNIPPET  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;; yasnippet
;; (require 'yasnippet) ;; not yasnippet-bundle
;; (yas/initialize)
;; (yas/load-directory "~/.emacs.d/public/snippets")

;; ;; (setq yas/trigger-key (kbd "s-e"))
;; ;; (add-hook 'yas/minor-mode-on-hook
;; ;;           (define-key yas/minor-mode-map yas/trigger-key 'yas/expand))

;; ;;; js2 & yasnippet
;; (add-hook 'js2-mode-hook #'yas/minor-mode-on)

;; (eval-after-load 'js2-mode
;;   '(progn
;;      (define-key js2-mode-map (kbd "TAB")
;;        (lambda()
;; 	 (interactive)
;; 	 (let ((yas/fallback-behavior 'return-nil))
;; 	   (unless (yas/expand)
;; 	     (indent-for-tab-command)
;; 	     (if (looking-back "^\s*")
;; 		 (back-to-indentation))))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; flymake
(require 'flymake)

;; helm
;; C-x c : préfixe pour les commandes Helm
(require 'helm-config)
(global-set-key (kbd "C-c h") 'helm-mini) ; buffers, fichiers récents etc.
(global-set-key (kbd "M-x") 'helm-M-x)	  ; remplace le M-x standard
;(global-set-key (kbd "C-x C-f") 'helm-find-files) ; remplace le sélecteur de fichier standard
;(helm-mode 0)

;;; lilypond
;; (autoload 'LilyPond-mode "lilypond-mode")
;; (setq auto-mode-alist
;;       (cons '("\\.ly$" . LilyPond-mode) auto-mode-alist))
;; (add-hook 'LilyPond-mode-hook (lambda () (turn-on-font-lock)))

;;; html
;; html mode pour perl template
(add-to-list 'auto-mode-alist '("\\.tt\\'" . html-mode))
;; mode pour html / xml
(add-to-list 'auto-mode-alist '("\\.xml\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . nxml-mode))

;;; css
;;(require 'css-complete) ; complétion des règles css
(require 'less-css-mode)
(setq less-css-compile-at-save t)
(setq less-css-lessc-command "lessc")

;;; yaml
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))

;;; markdown
(autoload 'markdown-mode "markdown-mode.el"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(provide 'conf-divers)
