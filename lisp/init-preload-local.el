;;; 本地配置

;;(global-linum-mode 1)
(require 'git-gutter)
(require 'eslint-fix)
(require 'emmet-mode)
(global-git-gutter-mode +1)
(display-time-mode 1)
;;;;;;;;;;;;;;
;rjsx-mode
;;;;;;;;;;;;;;;
(require 'js2-mode)
(require 'rjsx-mode)
(add-to-list 'auto-mode-alist '("\\.html\\'" . rjsx-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . rjsx-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . rjsx-mode))
(add-to-list 'auto-mode-alist '("\\.wxml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.wxss\\'" . css-mode))
;; rjsx缩进
(defadvice js-jsx-indent-line (after js-jsx-indent-line-after-hack activate)
   "Workaround sgml-mode and follow airbnb component style."
   (save-excursion
    (beginning-of-line)
    (if (looking-at-p "^ +\/?> *$")
      (delete-char sgml-basic-offset))
))

(add-hook 'rjsx-mode-hook 'hs-minor-mode)
(add-hook 'rjsx-mode-hook 'emmet-mode)
(add-hook 'web-mode-hook 'emmet-mode)
(add-hook 'rjsx-mode-hook 'git-gutter-mode)
(add-to-list 'load-path "~/.emacs.d/lisp/elpa-mirror")
(require 'elpa-mirror)
(setq package-archives '(("myelpa" . "~/myelpa/")))
(setq company-dabbrev-downcase nil)
(add-hook 'less-css-mode-hook
          (lambda ()
            (setq css-indent-offset 2)
            (setq indent-tabs-mode nil)
            )
          )
;; react
(add-hook 'rjsx-mode-hook
          (lambda ()
            (setq emmet-expand-jsx-className? t) ;; default nil
          ))
;; 微信小程序
(defun wxapp-mode-hook ()
  (setq emmet-expand-jsx-className? nil)
  (setq web-mode-markup-indent-offset 4)
  (setq web-mode-css-indent-offset 4)
  (setq web-mode-code-indent-offset 4))
(add-hook 'web-mode-hook 'wxapp-mode-hook)
(defun myts-mode-hook ()
  (setq-default typescript-indent-level 2)
  (setq-default typescript-expr-indent-offset 2))
(add-hook 'typescript-mode 'myts-mode-hook)
(setq-default typescript-indent-level 2)

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
             ("marmalade" . "http://marmalade-repo.org/packages/")
             ("melpa" . "http://melpa.milkbox.net/packages/")))


(use-package exec-path-from-shell
  :ensure t
  :custom
  (exec-path-from-shell-check-startup-files nil)
  :config
  (push "HISTFILE" exec-path-from-shell-variables)
  (exec-path-from-shell-initialize))

;; Make sure the local node_modules/.bin/ can be found (for eslint)
(use-package add-node-modules-path
  :ensure t
  :config
  ;; automatically run the function when rjsx-mode starts
  (eval-after-load 'rjsx-mode
    '(add-hook 'rjsx-mode-hook 'add-node-modules-path)))
(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode)
  ;; disable json-jsonlist checking for json files
  (setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(json-jsonlist)))
  ;; disable jshint since we prefer eslint checking
  (setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(javascript-jshint)))
  ;; use eslint with rjsx-mode for jsx files
  (flycheck-add-mode 'javascript-eslint 'rjsx-mode)
  (flycheck-add-mode 'javascript-eslint 'typescript-mode))
  
(eval-after-load 'flycheck
    '(progn
      (set-face-attribute 'flycheck-error nil :foreground "yellow" :background "red")))

(add-hook 'focus-out-hook 'save-buffer)

;;start 设置剪切板共享 
(defun copy-from-osx () 
(shell-command-to-string "pbpaste")) 
(defun paste-to-osx (text &optional push) 
(let ((process-connection-type nil)) 
(let ((proc (start-process"pbcopy" "*Messages*" "pbcopy"))) 
(process-send-string proc text) 
(process-send-eof proc)))) 
(setq interprogram-cut-function 'paste-to-osx) 
(setq interprogram-paste-function 'copy-from-osx) 
;;end 设置剪切板共享 


(desktop-save-mode t)
(setq desktop-restore-eager 5)
(setq desktop-lazy-verbose t)

(provide 'init-preload-local)
;;; init-preload-local.el ends here

