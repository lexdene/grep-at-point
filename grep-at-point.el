; 在工作目录下的所有文件中搜索当前光标下的单词
; 其原理只是将grep和thingatpt简单地结合一下

(provide 'grep-at-point)

(require 'thingatpt)

(defun grep-at-point (directory word extname)
  "grep the current word"
  (interactive
   (let (
         (origin-word (thing-at-point 'symbol)))
     (list
      (read-file-name "grep directory: " default-directory default-directory)
      (read-from-minibuffer "grep word: " origin-word)
      (read-from-minibuffer
       "file ext: "
       (default-file-pattern)
       )
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

(defun default-file-pattern ()
  "*.ext"
  (concat "*." (file-name-extension (buffer-file-name))))
