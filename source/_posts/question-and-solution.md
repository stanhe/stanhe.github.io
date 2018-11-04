---
title: Question-and-solutions
tags: emacs-lisp
date: 2018-11-03 12:22:06
---
<!-- ![image]() -->

### 1. 路径设置中的问题

最近在写一个windows上使用的emacs terminal插件，让emacs act as vscode的terminal，遇到一个查找父路径的问题，比如一个java项目，项目路径即父路径应该是有 settings和graldew的目录，而source code放在 src/main/Main.java 这样子，那么当我编辑了该文件后要运行 gradle run ，就应该在父路径下运行，所以我找到了下面的方法
```
(defun get-parent-dir (name)
  "Get the parent name dir."
  (locate-dominating-file default-directory name))

```
理论上可以直接用这个，但是我希望自己指定父路径，这时，我需要一个方法能够返回list中第一个非nil，想到用or 但是不知道怎么把list 拆开传给or。找到了 cl-some 这个方法
```
(defvar pop-find-parent-directory nil "find the files in parent directory,if find,return the path as parent directory,else try the next")

(defun get-project-root-directory (buffer)
  "find current project root,for git or gradle."
    (with-current-buffer buffer
      (if (setq parent (cl-some #'get-parent-dir pop-find-parent-directory))
	  parent
	(get-current-directory))))

```
之后又详细的研究了macro 补一个 or的实现
```
(defmacro get-not-nil (list)
  `(progn
     (or ,@list)))

(get-not-nil (nil nil "he" "hi") )

```
### 2. 使用关键字

我希望我的方法能像use-package一样使用 :init :config来配置，所以我查询了function的keyword。发现方法或者宏后面加*的都是 cl.el 的实现,cl的实现里支持 &key.
```
(defun* example (&rest args &key (a 1) (b 2) &allow-other-keys)
  (format "%s %s %s" args a b))
(example   :b "hello" 2)

(defun* my-example (name &key (a ) &allow-other-keys)
  (format "%s %s " name a))

(my-example "gradle" :b (message "hello"))
```
上面的方法确实可以传递keyword，但是并不能传递 (message "hello"),这种形式会被eval成 "hello"传递，所以又想到宏
```
(defmacro* test-macro (name &key (init) (config) &allow-other-keys)
  `(progn
     (message "name is :%s" ,name)
     (if (> ,(length name) 5)
	 ,init
       ,config)))

(macroexpand '(test-macro "hi" :init (message "ok") :config (message "config")))
(test-macro "hi1234" :init (message "ok") :config (message "config"))
(test-macro "ojbk")
```
如上就可以使用关键字来初始化了。<span id="question2"><font color=#0099ff>然而关键字后面有两个表达式的情况下不能解析,keyword 只认:init之后的第一个表达式.</font></span>

### 3 关键字解析问题

通过宏将quote形式的参数传入，调用while时，内部不需要宏参数解析。参考了 defcustom宏的源码
``` 
(defmacro handle-params-macro (&rest args)
  `(let ((params ',args)
	 current-arg
	 (init (list 'progn))
	 (config (list 'progn)))
    (while params
      (let ((value (pop params)))
    	    (cond
    	    ((symbolp value) (setq current-arg value))
    	    ((eq current-arg :init) (setq init (append init (list value))))
    	    ((eq current-arg :config) (setq config (append config (list value))))
	    )))
    (eval config)
    config;init back value.
    ))

(setq x (handle-params-macro :init (message "hi") (message "hello") :config "ok" (message "ok")))
x

```
上面的方法解决了[<font color=#ffa500>2中多form解析的问题</font>](#question2)，但是参数固定了，只有:init :config，要添加就需要修改代码，为了方便，让该宏自动查找:init这种参数并返回一个plist

### 4 keywords-to-plist

解决上面 #3 的 keyways 解析问题

```
(defmacro keywords-to-plist (&rest args)
  "handle the input keywords to progn plist."
  `(let ((params ',args)
	 current-arg
	 return-plist
	 tmp-value-arg
	 (init-arg (list 'progn)))
    (while params
      (let ((value (pop params)))
    	    (cond
    	     ((symbolp value)
	      (setq current-arg value)
	      (setq tmp-value-arg init-arg))
	    (t (setq tmp-value-arg (append tmp-value-arg (list value))))
	    )
	    (if (or (eq 0 (length params)) (and (symbolp (car params)) (not (eq nil (symbolp (car params))))))
		(setq return-plist (plist-put return-plist current-arg tmp-value-arg)))
	    ))
    return-plist
    ))


(setq x (keywords-to-plist "hello" "world" :init (message "hi") (message "hello") :config "ok" (message "ok")))

==> (nil ("hello" "world") :init (progn (message "hi") (message "hello")) :config (progn "ok" (message "ok"))) 
```

That's all.
