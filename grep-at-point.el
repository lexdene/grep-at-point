; 在工作目录下的所有文件中搜索当前光标下的单词
; 其原理只是将grep和thingatpt简单地结合一下

(provide 'grep-at-point)

(require 'thingatpt)

;; TODO: how to define module level variables in elisp?
(defvar grep-at-point-word-hist ())
(defvar grep-at-point-ext-hist ())
(defvar grep-at-point-exclude-dir-hist ())

(defvar grep-at-point-default-exclude-extname "")
(defvar grep-at-point-default-grep-command "grep")
(defcustom grep-at-point-default-exclude-dir "node_modules,.git"
    "exclude these dirs when grep")

(defun grep-at-point (directory word &optional extname exclude-extname grep-command exclude-dir)
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
      (read-from-minibuffer
       "exclude ext: " grep-at-point-default-exclude-extname)
      (read-from-minibuffer
       "grep command: " grep-at-point-default-grep-command)
      (read-from-minibuffer
       "exclude-dir: "
       (or (car grep-at-point-exclude-dir-hist) grep-at-point-default-exclude-dir)
       nil nil 'grep-at-point-exclude-dir-hist)
      )
     )
   )
  (grep
   (concat
    (format "cd %s &&" (replace-regexp-in-string " " "\\\\ " directory))
    (format " %s" (or grep-command grep-at-point-default-grep-command))
    (format " -nH -r -i \"%s\" ." (replace-regexp-in-string "\"" "\\\\\"" word))
    (if (and exclude-extname (not (string= "" exclude-extname))) (format " --exclude=\"%s\"" exclude-extname) "")
    (if (and extname (not (string= "" extname))) (format " --include=\"%s\"" extname) "")
    (if (and exclude-dir (not (string= "" exclude-dir))) (format " --exclude-dir={%s}" exclude-dir) "")
    )
   ))

(defun nopromp-grep-at-point ()
  "grep the current word without promp"
  (interactive)
  (grep-at-point
   (or (getenv "PWD") default-directory)
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
  (grep-at-point
   directory
   word
   extname
   grep-at-point-default-exclude-extname
   grep-at-point-default-grep-command
   (or (car grep-at-point-exclude-dir-hist) grep-at-point-default-exclude-dir)
   ))

(defun default-file-pattern ()
  "*.ext"
  (and
    (buffer-file-name)
    (concat "*." (file-name-extension (buffer-file-name)))))
