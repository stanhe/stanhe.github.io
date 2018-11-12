---
title: emacs-start-win-application
tags: emacs-lisp
date: 2018-11-06 15:59:59
---
![image](http://pcnl48lkv.bkt.clouddn.com//d2018-11-06/start.gif)

<center> emacs open win application </center>

### 1. emacs 启动win应用

既然可以用emacs启动explore,那应该也可以启动应用，所以我找到了w32-shell-execute 写了个方法
```
(defun open-win-application ()
	"start my application with w32."
	(interactive)
	(require 'ivy)
	(let ((app-list (loop for (k v) on my-run-application-plist by (function cddr) collect k)))
	  (ivy-read "Open-application: "
		    app-list
		    :action '(1 ("o" (lambda (name)
				       (w32-shell-execute "open" (plist-get my-run-application-plist (intern name)))) "open")
				("d" (lambda (name)
				       (message "application path is: %s " (plist-get my-run-application-plist (intern name)))) "directory")))))

```
然后把需要启动的快捷方式传入
```
;;put the shortcut to `d:/Eapps/'
(setq my-run-application-plist '(git-bash "d:/Eapps/git-bash.exe.lnk"
				chrome "d:/Eapps/chrome.exe.lnk"))

```

### 2. 自动路径

* 有prefix，可以自己输入路径，默认桌面
* 没有prefix，查看是否通过 custom-open-win-apps-dir 指定路径，如果没有，打开桌面
* 如果d:Eapps中的快捷方式如果有 git-bash，把属性中的起始位置去掉，可以打开当前文件所在的位置

```
(setq custom-open-win-apps-dir "d:/Eapps")
```
```
(defun open-win-application ()
	"start my application with w32, with prefix to input custom directory."
	(interactive)
	;(setq debug-on-error t)
	(let* ((desktop (concat "c:/Users/" user-login-name "/desktop/"))
	       (custom-app-dir (if (and custom-open-win-apps-dir (file-exists-p custom-open-win-apps-dir) (not current-prefix-arg))
				   custom-open-win-apps-dir
				 desktop)))
	  (ivy-read "Open application: "
		    #'read-file-name-internal
		    :matcher #'counsel--find-file-matcher
		    :initial-input custom-app-dir
		    :action (lambda (name) (w32-shell-execute "open"  name ))
		    :preselect (counsel--preselect-file)
		    :require-match 'confirm-after-completion
		    :history 'file-name-history
		    :caller 'open-file-application
		    )))

```
