---
title: emacs-dired-open
tags: emacs-lisp
date: 2018-11-08 10:21:00
---
![image](http://pcnl48lkv.bkt.clouddn.com//d2018-11-08/show.gif)
<center> open application in dired mode with "C-o" </center>
```
(define-key dired-mode-map (kbd "C-o") (lambda ()
					 (interactive)
					 (progn
					   (w32-shell-execute "open" (dired-filename-at-point))
					   (message "open: %s" (dired-filename-at-point)))))
```
