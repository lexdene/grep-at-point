; 在工作目录下的所有文件中搜索当前光标下的单词
; 其原理只是将grep和thingatpt简单地结合一下

(provide 'grep-at-point)

(require 'thingatpt)

;; emacs lisp 中, 如何优雅地定义全局变量?
(defvar grep-at-point-word-hist ())
(defvar grep-at-point-ext-hist ())

(defun grep-at-point (directory word extname)
  "grep the current word"
  (interactive
   (let (
         (origin-word (thing-at-point 'symbol))
         )
     (list
      ;; It seems that read-file-name function doesnot have a history arg
      (read-file-name "grep directory: " default-directory default-directory)
      (read-from-minibuffer "grep word: " origin-word nil nil 'grep-at-point-word-hist)
      (read-from-minibuffer
       "file ext: " (default-file-pattern) nil nil 'grep-at-point-ext-hist)
      )
     )
   )
  (grep
   (format
    "cd %s && grep -nH -r '%s' . --include=\"%s\""
    directory
    word
    extname
    )
   ))

(defun nopromp-grep-at-point ()
  "grep the current word without promp"
  (interactive)
  (grep-at-point
   (getenv "PWD")
   (thing-at-point 'symbol)
   (default-file-pattern)
   )
  )

(defun grep-selected-text (directory word extname)
  "grep the selected text"
  (interactive
    (let
      ((selected-text (buffer-substring (region-beginning) (region-end))))
    (list
      (read-file-name "grep directory: " default-directory default-directory)
      (read-from-minibuffer "grep word: " selected-text nil nil 'grep-at-point-word-hist)
      (read-from-minibuffer
       "file ext: " (default-file-pattern) nil nil 'grep-at-point-ext-hist))))
  (grep-at-point directory word extname))

(defun default-file-pattern ()
  "*.ext"
  (and
    (buffer-file-name)
    (concat "*." (file-name-extension (buffer-file-name)))))
