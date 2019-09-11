;;; 本地配置

(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")


;;(global-linum-mode 1)
(require 'git-gutter)
(require 'eslint-fix)
(require 'emmet-mode)
(global-git-gutter-mode +1)
(display-time-mode 1)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)


(require 'tide)
(load-theme 'sanityinc-solarized-dark t)
(flycheck-add-next-checker 'tsx-tide 'javascript-eslint)
;;(flycheck-add-next-checker 'jsx-tide 'javascript-eslint 'append)


;; 安装资源路径
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
             ("marmalade" . "http://marmalade-repo.org/packages/")
             ("melpa" . "http://melpa.milkbox.net/packages/")))

;;;;;;;;;;;;;;
;rjsx-mode
;;;;;;;;;;;;;;;
(require 'js2-mode)
(require 'rjsx-mode)
(add-to-list 'auto-mode-alist '("\\.html\\'" . html-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.wxml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.wxss\\'" . css-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . web-mode))

;; rjsx缩进
(defadvice js-jsx-indent-line (after js-jsx-indent-line-after-hack activate)
   "Workaround sgml-mode and follow airbnb component style."
   (save-excursion
    (beginning-of-line)
    (if (looking-at-p "^ +\/?> *$")
      (delete-char sgml-basic-offset))
))

;; typescript ;;;
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  (setq tide-sync-request-timeout 5)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'web-mode-hook #'setup-tide-mode)
(add-hook 'rjsx-mode-hook #'setup-tide-mode)
(require 'web-mode)
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "tsx" (file-name-extension buffer-file-name))
              (setup-tide-mode)
              (flycheck-select-checker 'tsx-tide)
              )))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "jsx" (file-name-extension buffer-file-name))
              (setup-tide-mode)
              )))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "js" (file-name-extension buffer-file-name))
              (setup-tide-mode)
              )))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "ts" (file-name-extension buffer-file-name))
              (setup-tide-mode)
              )))



(add-hook 'rjsx-mode-hook 'hs-minor-mode)
(add-hook 'rjsx-mode-hook 'emmet-mode)
(add-hook 'web-mode-hook 'emmet-mode)
(add-hook 'rjsx-mode-hook 'git-gutter-mode)
(add-hook 'web-mode-hook 'git-gutter-mode)
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


;; 微信小程序 tsx ----------------------------------------------------
(defun my-web-mode ()
  (setq emmet-expand-jsx-className? t)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-enable-auto-indentation nil)
  (setq web-mode-comment-style 2)
  (flycheck-select-checker 'javascript-eslint)
  (setq web-mode-enable-current-element-highlight t)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-enable-auto-quoting nil)
  (setq-default web-mode-comment-formats
              '(("java"       . "/*")
                ("javascript" . "//")
                ("typescript" . "//")
                ("jsx" . "//")
                ("tsx" . "//")
                ("php"        . "/*")))
)
(add-hook 'web-mode-hook 'my-web-mode)
;; end web-mode-hook ==============================


;; myts-mode-hook ----------------------------------------------------
(defun myts-mode-hook ()
  (setq-default typescript-indent-level 2)
  (setq-default typescript-expr-indent-offset 2))
(add-hook 'typescript-mode 'myts-mode-hook)
(setq-default typescript-indent-level 2)
;; end myts-mode-hook ================================


;; --------------------------------------------------
(use-package exec-path-from-shell
  :ensure t
  :custom
  (exec-path-from-shell-check-startup-files nil)
  :config
  (push "HISTFILE" exec-path-from-shell-variables)
  (exec-path-from-shell-initialize))
;; ===================================================


;; Make sure the local node_modules/.bin/ can be found (for eslint) -------------------------
(use-package add-node-modules-path
  :ensure t
  :config
  ;; automatically run the function when rjsx-mode starts
  (eval-after-load 'rjsx-mode
    '(add-hook 'rjsx-mode-hook 'add-node-modules-path))
  (eval-after-load 'web-mode
    '(add-hook 'web-mode-hook 'add-node-modules-path))
)
;; end node_modules ======================================


;; flycheck ----------------------------------------------------
(use-package flycheck
  :ensure t
  :custom
  (flycheck-display-errors-delay 0)
  (flycheck-check-syntax-automatically '(mode-enabled save))
  :config
  (global-flycheck-mode)
  ;; disable json-jsonlist checking for json files
  (setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(json-jsonlist)))
  ;; disable jshint since we prefer eslint checking
  (setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(javascript-jshint)))
  (setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(typescript-tslint)))
  ;; use eslint with web-mode for jsx files
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  ;; Workaround for eslint loading slow
  ;; https://github.com/flycheck/flycheck/issues/1129#issuecomment-319600923
  (advice-add 'flycheck-eslint-config-exists-p :override (lambda() t)))

;; end flycheck ================================================================


(add-hook 'focus-out-hook 'save-buffer)


;; 中英文对齐 begin

(defun create-frame-font-mac()          ;emacs 若直接启动 启动时调用此函数似乎无效
  (set-face-attribute
   'default nil :font "Menlo 12")
  ;; Chinese Font
  (dolist (charset '( han symbol cjk-misc bopomofo)) ;script 可以通过C-uC-x=查看当前光标下的字的信息
    (set-fontset-font (frame-parameter nil 'font)
                      charset
                      (font-spec :family "PingFang SC" :size 14)))

  (set-fontset-font (frame-parameter nil 'font)
                    'kana                 ;script ｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺ
                    (font-spec :family "Hiragino Sans" :size 14))
  (set-fontset-font (frame-parameter nil 'font)
                    'hangul               ;script 까까까까까까까까까까까까까까까까까까까까
                    (font-spec :family "Apple SD Gothic Neo" :size 16))

  )
(when (and (equal system-type 'darwin) (window-system))
  (add-hook 'after-init-hook 'create-frame-font-mac))

(defun create-frame-font-w32()          ;emacs 若直接启动 启动时调用此函数似乎无效
  (set-face-attribute
   'default nil :font "Courier New 10")
  ;; Chinese Font
  (dolist (charset '( han symbol cjk-misc bopomofo)) ;script 可以通过C-uC-x=查看当前光标下的字的信息
    (set-fontset-font (frame-parameter nil 'font)
                      charset
                      (font-spec :family "新宋体" :size 16)))

  (set-fontset-font (frame-parameter nil 'font)
                    'kana                 ;script ｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺｺ
                    (font-spec :family "MS Mincho" :size 16))
  (set-fontset-font (frame-parameter nil 'font)
                    'hangul               ;script 까까까까까까까까까까까까까까까까까까까까
                    (font-spec :family "GulimChe" :size 16)))

(when (and (equal system-type 'windows-nt) (window-system))
  (add-hook 'after-init-hook 'create-frame-font-w32))


(defun  emacs-daemon-after-make-frame-hook(&optional f) ;emacsclient 打开的窗口相关的设置
  ;; (when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
  ;; (when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
  ;; (when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
  (with-selected-frame f
    (when (window-system)
      (when (equal system-type 'darwin) (create-frame-font-mac))
      (when (equal system-type 'windows-nt) (create-frame-font-w32))
      ;; (set-frame-position f 160 80)
      ;; (set-frame-size f 140 50)
      ;; (set-frame-parameter f 'alpha 85)
      ;; (raise-frame)
      )))

(add-hook 'after-make-frame-functions 'emacs-daemon-after-make-frame-hook)
;; 中英文对齐 end

;;start 设置剪切板共享  GUI版本不需要 ------------------------------------
;;(defun copy-from-osx ()
;;(shell-command-to-string "pbpaste"))
;;(defun paste-to-osx (text &optional push)
;;(let ((process-connection-type nil))
;;(let ((proc (start-process"pbcopy" "*Messages*" "pbcopy")))
;;(process-send-string proc text)
;;(process-send-eof proc))))
;;(setq interprogram-cut-function 'paste-to-osx)
;;(setq interprogram-paste-function 'copy-from-osx)
;;end 设置剪切板共享 ====================================================

;; markdown 预览 ------------------------------------------
;; (add-hook 'markdown-mode-hook 'vmd-mode) ;; or add a hook...
;; ===================================================

;; desktop-save-mode ----------------------------------------------------
;;(desktop-save-mode t)
;;(setq desktop-restore-eager 5)
;;(setq desktop-lazy-verbose t)
;; end desktop-save-mode ===================================================

;; eshell 中文乱码 ----------------------------------------------------
;;(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
;;(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
;; end eshell 中文乱码 =================================================

(provide 'init-preload-local)
;;; init-preload-local.el ends here

