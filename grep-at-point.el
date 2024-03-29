; 在工作目录下的所有文件中搜索当前光标下的单词
; 其原理只是将grep和thingatpt简单地结合一下

(provide 'grep-at-point)

(require 'thingatpt)

;; TODO: how to define module level variables in elisp?
(defvar grep-at-point-word-hist ())
(defvar grep-at-point-ext-hist ())
(defvar grep-at-point-exclude-dir-hist ())
(defvar grep-at-point-hist nil "History list for grep-at-point.")

(defvar grep-at-point-default-grep-command "grep")
(defcustom grep-at-point-default-exclude-dir "node_modules,.git"
    "exclude these dirs when grep")
(defcustom grep-at-point-default-exclude-extname ""
    "exclude files with these ext name when grep")

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
  (grep-save-and-run
   (concat
    (format "cd %s &&" (replace-regexp-in-string " " "\\\\ " directory))
    (format " %s" (or grep-command grep-at-point-default-grep-command))
    (format " -nH -r -i \"%s\" ." (replace-regexp-in-string "\"" "\\\\\"" word))
    (if
     (and
      (not (string-empty-p exclude-extname))
      (string-empty-p extname))
     (format " --exclude=\"%s\"" exclude-extname) "")
    (if (not (string-empty-p extname))
        (format " --include=\"%s\"" extname) "")
    (if (not (string-empty-p exclude-dir))
        (format " --exclude-dir={%s}" exclude-dir) "")
    )
   ))

(defun string-empty-p (s)
  "is string nil or empty string"
  (or
    (not s)
    (string= "" s)
  )
)

(defun find-project-root()
  "find project root"
  (message (locate-dominating-file default-directory ".git")))

(defun nopromp-grep-at-point ()
  "grep the current word without promp"
  (interactive)
  (grep-at-point
   (or (find-project-root) default-directory)
   (thing-at-point 'symbol)
   (default-file-pattern)
   grep-at-point-default-exclude-extname
   grep-at-point-default-grep-command
   grep-at-point-default-exclude-dir
   )
  )

(defun grep-previous-command (command)
  (interactive
   (list
    (read-from-minibuffer "grep command:" (or (car grep-at-point-hist) grep-command))))
  (grep-save-and-run command))

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

(defun grep-save-and-run (command)
  (add-to-history 'grep-at-point-hist command)
  (grep command))
