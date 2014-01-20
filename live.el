(setq mac-command-key-is-meta t
      mac-command-modifier 'meta
      mac-option-modifier 'hyper
      mac-function-modifier 'super
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
                    git-gutter+
                    git-commit-mode
                    dired-details
                    goto-last-change
                    enotify
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

(setq dired-details-propagate-flag t)

(add-to-list 'package-archives
             '("gnu" . "http://elpa.gnu.org/packages/")
             '("marmalade" .      "http://marmalade-repo.org/packages/")
             '("melpa" . "http://melpa.milkbox.net/packages/"))

(progn
  (defvar active-project "~/DEV/gems/search_resource")

  (defun goto-active-project ()
    (interactive)
    (find-file active-project))

  (defun set-active-project ()
    (interactive)
    (setq active-project
          (ido-completing-read "PROJECT: "
                               (--filter (not (or (string= it "..")
                                                  (string= it ".")
                                                  (string= it ".DS_Store")))
                                         (directory-files (expand-file-name "~/DEV"))))))

  (defun current-active-project ()
    (interactive)
    (let ((curr (file-name-directory (buffer-file-name (current-buffer)))))
      (progn  (setq active-project curr)
              (message "setting project to %s" curr)))))

(global-set-key (kbd "<f8>") 'set-active-project)
(global-set-key (kbd "C-c p") 'current-active-project)
(global-set-key (kbd "RET") 'paredit-newline)
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


(progn
  (defun tmr-spork-shell ()
    "Invoke spork shell" ; Spork - love that name
    (interactive)
    (pop-to-buffer (get-buffer-create (generate-new-buffer-name "spork")))
    (shell (current-buffer))
    (process-send-string nil "cd .\n"); makes sure rvm variables set with .rvmrc
    (process-send-string nil "spork\n"))

  (defun tmr-devlog-shell ()
    "Tail the development log, shell"
    (interactive)
    (pop-to-buffer (get-buffer-create (generate-new-buffer-name "devlog")))
    (shell (current-buffer))
    (process-send-string nil "cd .\n"); makes sure rvm variables set with .rvmrc
    (process-send-string nil "tail -f log/development.log\n"))

  (defun tmr-testlog-shell ()
    "Tail the test log, shell"
    (pop-to-buffer (get-buffer-create (generate-new-buffer-name "testlog")))
    (shell (current-buffer))
    (process-send-string nil "cd .\n"); makes sure rvm variables set with .rvmrc
    (process-send-string nil "tail -f log/test.log\n"))

  (defun tmr-server-shell ()
    "Invoke rails ui server shell"
    (interactive)
    (pop-to-buffer (get-buffer-create (generate-new-buffer-name "server")))
    (shell (current-buffer))
    (process-send-string nil "cd .\n"); makes sure rvm variables set with .rvmrc
    (process-send-string nil "rails s\n"))

  (defun tmr-db-shell ()
    "Invoke rails dbconsole shell"
    (interactive)
    (pop-to-buffer (get-buffer-create (generate-new-buffer-name "dbconsole")))
    (shell (current-buffer))
    (process-send-string nil "cd .\n"); makes sure rvm variables set with .rvmrc
    (process-send-string nil "rails dbconsole\n"))

  (defun tmr-console-shell ()
    "Invoke rails console shell"
    (interactive)
    (pop-to-buffer (get-buffer-create (generate-new-buffer-name "console")))
    (shell (current-buffer))
    (process-send-string nil "cd .\n"); makes sure rvm variables set with .rvmrc
    (process-send-string nil "rails console\n"))

                                        ; I like to run all my tests in the same shell
  (defun tmr-rspec-shell ()
    "Invoke rspec shell"
    (interactive)
    (pop-to-buffer (get-buffer-create (generate-new-buffer-name "rspec")))
    (shell (current-buffer))
    (process-send-string nil "cd .\n"); makes sure rvm variables set with .rvmrc
    (process-send-string nil "rspec spec\n")) ; This is debatable, since spork wont be up yet

                                        ; The shell where I do most of my work
  (defun tmr-shell ()
    "Invoke plain old shell"
    (interactive)
    (pop-to-buffer (get-buffer-create (generate-new-buffer-name "sh")))
    (shell (current-buffer))
    (process-send-string nil "cd .\n")); makes sure rvm variables set with .rvmrc

                                        ; My everyday ide
  (defun tmr-ide-lite ()
    "Spawn several shells for a mini Rails IDE"
    (interactive)
    (progn (tmr-spork-shell)
           (tmr-shell)
           (tmr-server-shell)
           (tmr-rspec-shell)))

                                        ; When I am doing a big debug session
  (defun tmr-ide-full ()
    "Spawn several shells for a full Rails IDE"
    (interactive)
    (progn (tmr-spork-shell)
           (tmr-shell)
           (tmr-server-shell)
           (tmr-console-shell)
           (tmr-db-shell)
           (tmr-devlog-shell)
           (tmr-testlog-shell)
           (tmr-rspec-shell))))
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
(add-hook 'ruby-mode-hook 'projectile-mode)
(add-hook 'ruby-mode-hook 'paredit-mode)
(add-hook 'ruby-mode-hook 'ruby-end-mode)

(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)


(eval-after-load 'windmove (lambda () (windmove-default-keybindings)))
(undo-tree-mode -1 )

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

  (global-set-key (kbd "M-z") 'helm-projectile)
  (global-set-key (kbd "M-x") 'smex)

  (global-set-key (kbd "M-X") 'smex-major-mode-commands)
  ;; This is your old M-x.
  (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
  (live-add-packs '(~/.live-packs/hooptie45-pack)))
