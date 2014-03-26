; 在工作目录下的所有文件中搜索当前光标下的单词
; 其原理只是将grep和thingatpt简单地结合一下

(provide 'grep-at-point)
(provide 'nopromp-grep-at-point)

(require 'thingatpt)
(defun grep-at-point (directory word extname)
  "grep the current word"
  (interactive
   (let (
         (origin-word (thing-at-point 'symbol)))
     (list
      (read-file-name "grep directory: " (getenv "PWD"))
      (read-from-minibuffer "grep word: " origin-word)
      (read-from-minibuffer "file ext: " "*")
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
   (concat "*." (file-name-extension (buffer-name)))
   )
  )
