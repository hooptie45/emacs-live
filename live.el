(setq mac-command-key-is-meta t
      mac-command-modifier 'meta
      mac-option-modifier 'hyper
      mac-function-modifier 'super
      debug-on-quit t
      truncate-lines t)

(dolist (mode '(ruby espresso))
  (add-hook (intern (format "%s-mode-hook" mode))
            '(lambda ()
               (add-to-list (make-local-variable 'paredit-space-for-delimiter-predicates)
                            (lambda (_ _) nil))
               (enable-paredit-mode))))
(require 'package)

(setq package-list '(elscreen
                    evil-leader
                    evil-paredit
                    evil
                    git-blame
                    workgroups
                    git-gutter+
                    git-commit-mode
                    key-chord
                    dired-details
                    goto-last-change
                    helm-projectile
                    helm
                    js2-mode
                    paredit
                    projectile
                    pkg-info
                    epl
                    dash
                    ruby-end
                    ruby-hash-syntax
                    ruby-tools
                    s
                    undo-tree))
; list the repositories containing them
(setq package-archives '(("elpa" . "http://tromey.com/elpa/")
                         ("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")))

; activate all the packages (in particular autoloads)
(package-initialize)

; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))

; install the missing packages
(dolist (package package-list)
  (when (not (package-installed-p package))
    (package-install package)))

(package-initialize)

(require 'projectile)
(require 'evil)
(require 'elscreen)
(require 'ruby-tools)
(require 'evil)
(require 'dired-details)
(require 'helm-adaptative)

(helm-adaptative-mode)
  ;; Highlighting in editmsg-buffer for magit
(add-to-list 'auto-mode-alist '("COMMIT_EDITMSG" . fundamental-mode))
(setq dired-details-propagate-flag t)

(progn
  (defvar active-project "~/DEV/gems/search_resource")

  (defun goto-active-project ()
    (interactive)
    (find-file active-project))

  (defun make-current-the-active-project ()
    (interactive)
    (setq active-project
	  (when (y-or-n-p (format "Make %s the active project?" default-directory))
	    (setq active-project default-directory))))

  (defun set-active-project ()
    (interactive)
    (setq active-project
	  (ido-completing-read "PROJECT: "
			       (--filter (not (or (string= it "..")
						  (string= it ".")
						  (string= it ".DS_Store")))
					 (directory-files (expand-file-name "~/DEV")))))))

(global-set-key (kbd "<f8>") 'set-active-project)
(global-set-key (kbd "C-c p") 'current-active-project)
(global-set-key (kbd "RET") 'paredit-newline)
(global-set-key (kbd "<f10>") 'make-current-the-active-project)
(global-set-key (kbd "H-g") 'goto-active-project)
(global-set-key (kbd "C-x h") 'help)
(global-set-key (kbd "H-s") 'fixup-whitespace)
(global-set-key (kbd "M-S-<up>") 'projectile-rails-find-current-spec)

(elscreen-start)
(windmove-default-keybindings)
;;
;; (global-set-key (kbd "C-=") 'er/expand-region)
;; ;; (add-to-list 'load-path "~/.emacs.d/evil")
;; ;; (evil-mode 1)


(add-hook 'after-init-hook 'server-start)
(add-hook 'server-done-hook
          (lambda ()
            (shell-command
             "screen -r -X select $(cat ~/tmp/emacsclient-caller)")))


(eval-after-load 'elscreen (lambda ()
                             (progn
                               (global-set-key (kbd "H-<right>") 'elscreen-next)
                               (global-set-key (kbd "H-<left>") 'elscreen-previous)
                               (global-set-key (kbd "H-<down>") 'elscreen-swap)
                               (global-set-key (kbd "H-<up>") 'elscreen-swap))
                             ))

(eval-after-load 'evil (lambda ()
                         (progn
                           (require 'evil-leader)
                           (global-evil-leader-mode)
                           (evil-leader/set-key "t" 'projectile-toggle-between-implementation-and-test)
                           (evil-leader/set-key "g" 'magit-status)
                           (define-key evil-normal-state-map "c" nil)
                           (define-key evil-motion-state-map "cu" 'universal-argument)
                           (global-set-key (kbd "H-v") 'turn-on-evil-mode)
                           (global-set-key (kbd "H-V") 'turn-off-evil-mode))))



(setq-default truncate-lines t)
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)


(eval-after-load 'windmove (lambda () (windmove-default-keybindings)))
(undo-tree-mode -1 )
(global-set-key (kbd "H-<left>") 'elscreen-previous)
(global-set-key (kbd "H-<right>") 'elscreen-next)
(global-set-key (kbd "H-S-<down>") 'elscreen-clone)
(global-set-key (kbd "H-k") 'elscreen-kill)
(global-set-key (kbd "H-<up>") 'elscreen-swap)
(global-set-key (kbd "H-<down>") 'elscreen-create)

(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "H-r") 'helm-show-kill-ring)

(global-set-key (kbd "s-k") '(lambda () (interactive) (kill-buffer (current-buffer))))
(global-set-key (kbd "C-c C-v") '(lambda ()
                                       (interactive)
                                       (progn
                                         (save-buffer)
                                         (server-edit ))))

(defun indent-def ()
  (interactive)
  (progn
    (narrow-to-defun
     (indent-region (point-min) (point-max)))
    (widen)))

(progn

  (define-key global-map (kbd "M-z") 'dired-jump)
  (define-key global-map (kbd "H-t") 'toggle-truncate-lines)
  (define-key global-map (kbd "s-k") '(lambda () (interactive) (kill-buffer-if-not-modified (current-buffer))))
  (define-key global-map (kbd "H-s") 'fixup-whitespace)
  (define-key global-map (kbd "H-e") 'hippie-expand )
  (add-hook 'clojure-mode-hook 'paredit-mode)


  (set-variable 'magit-emacsclient-executable
                "/Applications/Emacs.app/Contents/MacOS/bin/emacsclient")
  (global-set-key (kbd "M-S-<up>") 'projectile-toggle-between-implementation-and-test)
  (global-set-key (kbd "s-/") 'indent-def)

  (global-set-key (kbd "C-z C-z") 'helm-projectile)
  (global-set-key (kbd "M-x") 'smex)

  (global-set-key (kbd "M-X") 'smex-major-mode-commands)
  ;; This is your old M-x.
  (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
  (live-add-packs '(~/.live-packs/hooptie45-pack)))

(evil-mode -1)
(add-to-list 'auto-mode-alist '("COMMIT_EDITMSG" . git-commit-mode))
(global-set-key (kbd "M-z") 'dired-jump)
(global-set-key (kbd "s-k") '(lambda () (interactive) (kill-buffer (current-buffer))))

(require 'key-chord)
(key-chord-mode 1)
(key-chord-define global-map "gg" 'magit-status)

(defadvice he-substitute-string (after he-paredit-fix)
  "remove extra paren when expanding line in paredit"
  (if (and paredit-mode (equal (substring str -1) ")"))
      (progn (backward-delete-char 1) (forward-char))))
(ad-activate 'he-substitute-string)

(global-set-key (kbd "C-x C-c") nil)
(global-set-key (kbd "C-x C-c") (lambda () (interactive) (progn (save-buffer) (server-edit))))


;; (global-set-key (kbd "C-x C-c") nil)
(require 'workgroups)

(workgroups-mode 1)

(defvar dotfiles-dir (f-expand "~/.emacs.d"))

(let ((dotfiles-dir "~/.emacs.d"))
  (add-to-list 'load-path (f-expand "vendor/Enhanced-Ruby-Mode/" dotfiles-dir))
  (add-to-list 'load-path (f-expand "vendor/emacs-pry/" dotfiles-dir)))

(require 'ruby-mode)
(require 'pry)
(add-hook 'ruby-mode-hook 'projectile-mode)
(add-hook 'ruby-mode-hook 'paredit-mode)
(add-hook 'ruby-mode-hook 'ruby-end-mode)
