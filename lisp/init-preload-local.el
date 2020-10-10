;;; Commentary
(condition-case nil
    (require 'use-package)
  (file-error
   (require 'package)
   (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
   (package-initialize)
   (package-refresh-contents)
   (package-install 'use-package)
   (require 'use-package)))

;;; init-preload-local.el --- 本地配置
;;; 安装资源路径
(require 'package)
;;(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;;(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)
(setq package-archives '(
                         ("gnu"   . "https://elpa.emacs-china.org/gnu/")
                         ("melpa" . "https://elpa.emacs-china.org/melpa/")
                         ))
;;;;;;;;;;;;;;
;; cl - Common Lisp Extension
(require 'cl)
(require 'web-mode)

;; Add Packages
(defvar my/packages '(
                      tide
                      monokai-theme
                      ) "Default packages")

(setq package-selected-packages my/packages)

(defun my/packages-installed-p ()
  (loop for pkg in my/packages
        when (not (package-installed-p pkg)) do (return nil)
        finally (return t)))

(unless (my/packages-installed-p)
  (message "%s" "Refreshing package database...")
  (package-refresh-contents)
  (dolist (pkg my/packages)
    (when (not (package-installed-p pkg))
      (package-install pkg))))
;;;;;;;;;; 安装必要的东西
(global-hl-line-mode 1) ;; 光标所在行高亮
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(setq make-backup-files nil)

;;(global-linum-mode 1)
(require 'git-gutter)
(require 'eslint-fix)
(require 'emmet-mode)
(global-git-gutter-mode +1)
(display-time-mode 1)


;; (add-to-list 'package-archives
;;              '("melpa" . "https://melpa.org/packages/") t)




(require 'tide)
;;(load-theme 'sanityinc-solarized-dark t)
(flycheck-add-next-checker 'tsx-tide 'javascript-eslint)
(flycheck-add-next-checker 'typescript-tide 'javascript-eslint)

                                        ;rjsx-mode
;;;;;;;;;;;;;;;
;; (require 'js2-mode)
;; (require 'rjsx-mode)
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.wxml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.wxss\\'" . css-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))

;; rjsx缩进
(defadvice js-jsx-indent-line (after js-jsx-indent-line-after-hack activate)
  "Workaround sgml-mode and follow airbnb component style."
  (save-excursion
    (beginning-of-line)
    (if (looking-at-p "^ +\/?> *$")
        (delete-char sgml-basic-offset))
    ))
;; 自动补全插件
;; (use-package company-tabnine :ensure t)
;; (add-to-list 'company-backends #'company-tabnine)
;; 自动补全插件 ends

;; tide ;;; 原本自己写的
;; (defun setup-tide-mode ()
;;   (interactive)
;;   (tide-setup)
;;   (flycheck-mode +1)
;;   (eldoc-mode +1)
;;   (tide-hl-identifier-mode +1)
;;   (setq tide-sync-request-timeout 5)
;;   ;; company is an optional dependency. You have to
;;   ;; install it separately via package-install
;;   ;; `M-x package-install [ret] company`
;;   (company-mode +1)
;;   (setq company-backends
;;         (remove 'company-css company-backends))  )

;; ts
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))
;; go 语言相关配置
(require 'go-mode)
(defun go-mode-setup ()
  (setq compile-command "CONSUL_HTTP_HOST=10.227.21.68 SEC_MYSQL_AUTH=1 TCE_PSM=ad.pangle.site RUNTIME_IDC_NAME=boe doas -p ad.pangle.site output/bootstrap.sh")
  (define-key (current-local-map) "\C-c\C-c" 'compile)
  (go-eldoc-setup)
  ;;Format before saving
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)
  (local-set-key (kbd "M-.") 'godef-jump))
(add-hook 'go-mode-hook 'go-mode-setup)
;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)
(add-hook 'go-mode-hook #'go-mode-setup)

(defun protobuf-mod-setup ()
  (display-line-numbers-mode)
  (local-set-key (kbd "M-p") 'symbol-overlay-jump-prev)
  (local-set-key (kbd "M-n") 'symbol-overlay-jump-next)  )
(add-hook 'protobuf-mode-hook #'protobuf-mod-setup)

(defconst my-protobuf-style
  '((c-basic-offset . 4)

    (indent-tabs-mode . nil)))

(add-hook 'protobuf-mode-hook
          (lambda () (c-add-style "my-style" my-protobuf-style t)))




;; formats the buffer before saving
;; (add-hook 'after-save-hook 'tide-format)
(add-hook 'typescript-mode-hook #'setup-tide-mode)

(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "tsx" (file-name-extension buffer-file-name))
              (setup-tide-mode)
              ;;(flycheck-select-checker 'javascript-eslint)
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
(add-hook 'typescript-mode-hook
          (lambda ()
            (when (string-equal "ts" (file-name-extension buffer-file-name))
              (setup-tide-mode)
              (flycheck-select-checker 'typescript-tide)
              )))



;;(add-hook 'rjsx-mode-hook 'hs-minor-mode)
;;(add-hook 'rjsx-mode-hook 'emmet-mode)
;;(add-hook 'rjsx-mode-hook 'git-gutter-mode)
(add-hook 'web-mode-hook 'emmet-mode)
(add-hook 'web-mode-hook 'git-gutter-mode)
;;(add-to-list 'load-path "~/.emacs.d/lisp/elpa-mirror")
;;(require 'elpa-mirror)
;;(setq package-archives '(("myelpa" . "~/myelpa/")))
(setq company-dabbrev-downcase nil)
(add-hook 'less-css-mode-hook
          (lambda ()
            (setq css-indent-offset 2)
            (setq indent-tabs-mode nil)
            )
          )
(add-hook 'scss-mode-hook
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

(defun my-web-mode ()
  ;; (flycheck-select-checker 'javascript-eslint)
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 2)
  (setq emmet-expand-jsx-className? t)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-attr-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-enable-auto-indentation nil)
  (setq web-mode-comment-style 2)
  (setq web-mode-enable-current-element-highlight t)
  (setq web-mode-enable-current-column-highlight t)
  (setq web-mode-enable-auto-quoting nil)
  (setq web-mode-enable-literal-interpolation t)
  ;;(set-fase-attribute 'web-mode-html-tag-unclosed-face nil :foreground "blue")
  (set-face-attribute 'web-mode-interpolate-color1-face nil :foreground "white")
  (set-face-attribute 'web-mode-interpolate-color2-face nil  :foreground "orange")
  (set-face-attribute 'web-mode-interpolate-color3-face nil :foreground "yellow")
  (global-set-key (kbd "RET") 'newline)
  (global-set-key (kbd "M-.") 'tide-jump-to-definition)
  (global-set-key (kbd "M-,") 'tide-jump-back)
  (add-to-list 'web-mode-indentation-params '("lineup-args" . nil))
  (add-to-list 'web-mode-indentation-params '("lineup-calls" . nil))
  (add-to-list 'web-mode-indentation-params '("lineup-concats" . nil))
  (add-to-list 'web-mode-indentation-params '("lineup-ternary" . nil))
  (setq-default web-mode-comment-formats
                '(("java"       . "/*")
                  ("javascript" . "//")
                  ("typescript" . "//")
                  ("jsx" . "//")
                  ("tsx" . "//")
                  ("php"        . "/*")))
  )
(add-hook 'web-mode-hook 'my-web-mode)
(defun eslint-fix-and-check-again ()
  (eslint-fix)
  (flycheck-buffer))

(eval-after-load 'web-mode
  '(add-hook 'web-mode-hook (lambda () (add-hook 'after-save-hook 'eslint-fix-and-check-again nil t))))
(eval-after-load 'typescript-mode
  '(add-hook 'typescript-mode-hook (lambda () (add-hook 'after-save-hook 'eslint-fix-and-check-again nil t))))
;; end web-mode-hook ==============================


;; myts-mode-hook ----------------------------------------------------
;; (defun myts-mode-hook ()
;;   (setq-default typescript-indent-level 2)
;;   (setq-default typescript-expr-indent-offset 2))
;;(add-hook 'typescript-mode 'myts-mode-hook)
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
  ;; (eval-after-load 'rjsx-mode
  ;;   '(add-hook 'rjsx-mode-hook 'add-node-modules-path))
  (eval-after-load 'web-mode
    '(add-hook 'web-mode-hook 'add-node-modules-path))
  )
;; end node_modules ======================================

;; flycheck ----------------------------------------------------
(use-package flycheck
  :ensure t
  :custom
  (flycheck-display-errors-delay 0)
  (flycheck-check-syntax-automatically '(save))
  :config
  (flycheck-mode)
  ;; disable json-jsonlist checking for json files
  (setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(json-jsonlist)))
  ;; disable jshint since we prefer eslint checking
  ;; (setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(javascript-jshint)))
  ;; (setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(typescript-tslint)))
  ;; use eslint with web-mode for jsx files
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  ;; (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)
  ;; Workaround for eslint loading slow
  ;; https://github.com/flycheck/flycheck/issues/1129#issuecomment-319600923
  (advice-add 'flycheck-eslint-config-exists-p :override (lambda() t)))

;; end flycheck ================================================================


;;(add-hook 'focus-out-hook 'save-buffer)


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

;; 不喜欢的快捷键
(global-unset-key (kbd "M-l")) ;; 转小写
(global-unset-key (kbd "M-u")) ;; 转大写
(global-unset-key (kbd "M-c")) ;; 转首字母大写
;; 不喜欢的快捷键 end

;;start 设置剪切板共享  GUI版本不需要 ------------------------------------
;; (defun copy-from-osx ()
;;   (shell-command-to-string "pbpaste"))
;; (defun paste-to-osx (text &optional push)
;;   (let ((process-connection-type nil))
;;     (let ((proc (start-process"pbcopy" "*Messages*" "pbcopy")))
;;       (process-send-string proc text)
;;       (process-send-eof proc))))
;; (setq interprogram-cut-function 'paste-to-osx)
;; (setq interprogram-paste-function 'copy-from-osx)
;;end 设置剪切板共享 ====================================================

;; markdown 预览 ------------------------------------------
;; (add-hook 'markdown-mode-hook 'vmd-mode) ;; or add a hook...
;; ===================================================

;; desktop-save-mode ----------------------------------------------------
;;(desktop-save-mode nil)
;;(setq desktop-restore-eager 5)
;;(setq desktop-lazy-verbose t)
;; end desktop-save-mode ===================================================

;; eshell 中文乱码 ----------------------------------------------------
;;(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
;;(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
;; end eshell 中文乱码 =================================================



;; Install use-package

;; (use-package lsp-mode :ensure t)
(use-package lsp-mode
  :config
  (setq lsp-ui-doc-enable nil)
  :commands lsp)
(use-package lsp-dart
  :ensure t
  :hook (dart-mode . lsp)
  :custom
  (lsp-dart-suggest-from-unimported-libraries nil))

;; Optional packages
(use-package projectile :ensure t) ;; project management
(use-package yasnippet
  :ensure t
  :config (yas-global-mode)) ;; snipets
(use-package lsp-ui :ensure t) ;; UI for LSP


;; Assuming usage with dart-mode
;; (use-package dart-mode
;;   ;; Optional
;;   :hook (dart-mode . flutter-test-mode))

(use-package flutter
  :after dart-mode
  :bind (:map dart-mode-map
              ("C-M-x" . #'flutter-run-or-hot-reload))
  :custom
  (flutter-sdk-path "/Users/AllanJane/workspace/ljm/flutter/"))

;; ;; Optional
;; (use-package flutter-l10n-flycheck
;;   :after flutter
;;   :config
;;   (flutter-l10n-flycheck-setup))

(provide 'init-preload-local)
;;; init-preload-local.el ends here
