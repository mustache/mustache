;;; tpl-mode.el -- a major mode for editing Google CTemplate files.
;;; By Tony Gentilcore, July 2006
;;;
;;; Very minor, backwards compatible changes added for Mustache compatibility
;;; by Chris Wanstrath, October 2009
;;;
;;; TO USE:
;;; 1) Copy this file somewhere you in emacs load-path.  To see what
;;;    your load-path is, run inside emacs: C-h v load-path<RET>
;;; 2) Add the following two lines to your .emacs file:
;;;    (setq auto-mode-alist (cons '("\\.tpl$" . tpl-mode) auto-mode-alist))
;;;    (autoload 'tpl-mode "tpl-mode" "Major mode for editing CTemplate files." t)
;;; 3) Optionally (but recommended), add this third line as well:
;;;    (add-hook 'tpl-mode-hook '(lambda () (font-lock-mode 1)))
;;; ---
;;;
;;; While the CTemplate language can be used for any types of text,
;;; this mode is intended for using CTemplate to write HTML.
;;;
;;; The indentation still has minor bugs due to the fact that
;;; templates do not require valid HTML.
;;;
;;; It would be nice to be able to highlight attributes of HTML tags,
;;; however this is difficult due to the presence of CTemplate symbols
;;; embedded within attributes.

(eval-when-compile
  (require 'font-lock))

(defgroup tpl-mode nil
  "Major mode for editing Google CTemplate and Mustache files"
  :group 'languages)

(defvar tpl-mode-version "1.1"
  "Version of `tpl-mode.el'.")

(defvar tpl-mode-abbrev-table nil
  "Abbrev table for use in tpl-mode buffers.")

(define-abbrev-table 'tpl-mode-abbrev-table ())

(defcustom tpl-mode-hook nil
  "*Hook that runs upon entering tpl-mode."
  :type 'hook)

(defvar tpl-mode-map nil
  "Keymap for tpl-mode major mode")

(if tpl-mode-map
    nil
  (setq tpl-mode-map (make-sparse-keymap)))

(define-key tpl-mode-map "\t" 'tpl-indent-command)
(define-key tpl-mode-map "\C-m" 'reindent-then-newline-and-indent)
(define-key tpl-mode-map "\C-ct" 'tpl-insert-tag)
(define-key tpl-mode-map "\C-cv" 'tpl-insert-variable)
(define-key tpl-mode-map "\C-cs" 'tpl-insert-section)


(defvar tpl-mode-syntax-table nil
  "Syntax table in use in tpl-mode buffers.")

;; Syntax table.
(if tpl-mode-syntax-table
    nil
  (setq tpl-mode-syntax-table (make-syntax-table text-mode-syntax-table))
  (modify-syntax-entry ?<  "(>  " tpl-mode-syntax-table)
  (modify-syntax-entry ?>  ")<  " tpl-mode-syntax-table)
  (modify-syntax-entry ?\" ".   " tpl-mode-syntax-table)
  (modify-syntax-entry ?\\ ".   " tpl-mode-syntax-table)
  (modify-syntax-entry ?'  "w   " tpl-mode-syntax-table))

(defvar tpl-basic-offset 2
  "The basic indentation offset.")

;; Constant regular expressions to identify template elements.
(defconst tpl-mode-tpl-token "[a-zA-Z][a-zA-Z0-9_:=\?!-]*?")
(defconst tpl-mode-section (concat "\\({{[#/]\s*"
                                   tpl-mode-tpl-token
                                   "\s*}}\\)"))
(defconst tpl-mode-open-section (concat "\\({{#\s*"
                                        tpl-mode-tpl-token
                                        "\s*}}\\)"))
(defconst tpl-mode-close-section (concat "{{/\\(\s*"
                                         tpl-mode-tpl-token
                                         "\s*\\)}}"))
;; TODO(tonyg) Figure out a way to support multiline comments.
(defconst tpl-mode-comment "\\({{!.*?}}\\)")
(defconst tpl-mode-include (concat "\\({{>\s*"
                                   tpl-mode-tpl-token
                                   "\s*}}\\)"))
(defconst tpl-mode-variable (concat "\\({{\s*"
                                    tpl-mode-tpl-token
                                    "\s*}}\\)"))
(defconst tpl-mode-builtins
  (concat
   "\\({{\\<\s*"
   (regexp-opt
    '("BI_NEWLINE" "BI_SPACE")
    t)
   "\s*\\>}}\\)"))
(defconst tpl-mode-close-section-at-start (concat "^[ \t]*?"
                                                  tpl-mode-close-section))

;; Constant regular expressions to identify html tags.
;; Taken from HTML 4.01 / XHTML 1.0 Reference found at:
;; http://www.w3schools.com/tags/default.asp.
(defconst tpl-mode-html-constant "\\(&#?[a-z0-9]\\{2,5\\};\\)")
(defconst tpl-mode-pair-tag
  (concat
   "\\<"
   (regexp-opt
    '("a" "abbr" "acronym" "address" "applet" "area" "b" "bdo"
      "big" "blockquote" "body" "button" "caption" "center" "cite"
      "code" "col" "colgroup" "dd" "del" "dfn" "dif" "div" "dl"
      "dt" "em" "fieldset" "font" "form" "frame" "frameset" "h1"
      "h2" "h3" "h4" "h5" "h6" "head" "html" "i" "iframe" "ins"
      "kbd" "label" "legend" "li" "link" "map" "menu" "noframes"
      "noscript" "object" "ol" "optgroup" "option" "p" "pre" "q"
      "s" "samp" "script" "select" "small" "span" "strike"
      "strong" "style" "sub" "sup" "table" "tbody" "td" "textarea"
      "tfoot" "th" "thead" "title" "tr" "tt" "u" "ul" "var")
    t)
   "\\>"))
(defconst tpl-mode-standalone-tag
  (concat
   "\\<"
   (regexp-opt
    '("base" "br" "hr" "img" "input" "meta" "param")
    t)
   "\\>"))
(defconst tpl-mode-open-tag (concat "<\\("
                                    tpl-mode-pair-tag
                                    "\\)"))
(defconst tpl-mode-close-tag (concat "</\\("
                                     tpl-mode-pair-tag
                                     "\\)>"))
(defconst tpl-mode-close-tag-at-start (concat "^[ \t]*?"
                                              tpl-mode-close-tag))

(defconst tpl-mode-blank-line "^[ \t]*?$")
(defconst tpl-mode-dangling-open (concat "\\("
                                         tpl-mode-open-section
                                         "\\)\\|\\("
                                         tpl-mode-open-tag
                                         "\\)[^/]*$"))

(defun tpl-indent-command ()
  "Command for indenting text. Just calls tpl-indent."
  (interactive)
  (tpl-indent))

(defun tpl-insert-tag (tag)
  "Inserts an HTML tag."
  (interactive "sTag: ")
  (tpl-indent)
  (insert (concat "<" tag ">"))
  (insert "\n\n")
  (insert (concat "</" tag ">"))
  (tpl-indent)
  (forward-line -1)
  (tpl-indent))

(defun tpl-insert-variable (variable)
  "Inserts a tpl variable."
  (interactive "sVariable: ")
  (insert (concat "{{" variable "}}")))

(defun tpl-insert-section (section)
  "Inserts a tpl section."
  (interactive "sSection: ")
  (tpl-indent)
  (insert (concat "{{#" section "}}\n"))
  (insert "\n")
  (insert (concat "{{/" section "}}"))
  (tpl-indent)
  (forward-line -1)
  (tpl-indent))

;; Function to control indenting.
(defun tpl-indent ()
  "Indent current line"
  ;; Set the point to beginning of line.
  (beginning-of-line)
  ;; If we are at the beginning of the file, indent to 0.
  (if (bobp)
      (indent-line-to 0)
    (let ((tag-stack 1) (close-tag "") (cur-indent 0) (old-pnt (point-marker))
          (close-at-start) (open-token) (dangling-open))
      (progn
        ;; Determine if this is a template line or an html line.
        (if (looking-at "^[ \t]*?{{")
            (setq close-at-start tpl-mode-close-section-at-start
                  open-token "{{#")
          (setq close-at-start tpl-mode-close-tag-at-start
                open-token "<"))
        ;; If there is a closing tag at the start of the line, search back
        ;; for its opener and indent to that level.
        (if (looking-at close-at-start)
            (progn
              (save-excursion
                (setq close-tag (match-string 1))
                ;; Keep searching for a match for the close tag until
                ;; the tag-stack is 0.
                (while (and (not (bobp))
                            (> tag-stack 0)
                            (re-search-backward (concat open-token
                                                        "\\(/?\\)"
                                                        close-tag) nil t))
                  (if (string-equal (match-string 1) "/")
                      ;; We found another close tag, so increment tag-stack.
                      (setq tag-stack (+ tag-stack 1))
                    ;; We found an open tag, so decrement tag-stack.
                    (setq tag-stack (- tag-stack 1)))
                  (setq cur-indent (current-indentation))))
              (if (> tag-stack 0)
                  (save-excursion
                    (forward-line -1)
                    (setq cur-indent (current-indentation)))))
          ;; This was not a closing tag, so we check if the previous line
          ;; was an opening tag.
          (save-excursion
            ;; Keep moving back until we find a line that is not blank
            (while (progn
                     (forward-line -1)
                     (and (not (bobp)) (looking-at tpl-mode-blank-line))))
            (setq cur-indent (current-indentation))
            (if (re-search-forward tpl-mode-dangling-open old-pnt t)
                (setq cur-indent (+ cur-indent tpl-basic-offset)))))
        ;; Finally, we execute the actual indentation.
        (if (> cur-indent 0)
            (indent-line-to cur-indent)
          (indent-line-to 0))))))

;; controls highlighting
(defconst tpl-mode-font-lock-keywords
  (list
   (list tpl-mode-section
         '(1 font-lock-keyword-face))
   (list tpl-mode-comment
         '(1 font-lock-comment-face))
   (list tpl-mode-include
         '(1 font-lock-builtin-face))
   (list tpl-mode-builtins
         '(1 font-lock-variable-name-face))
   (list tpl-mode-variable
         '(1 font-lock-reference-face))
   (list (concat "</?\\(" tpl-mode-pair-tag "\\)")
         '(1 font-lock-function-name-face))
   (list (concat "<\\(" tpl-mode-standalone-tag "\\)")
         '(1 font-lock-function-name-face))
   (list tpl-mode-html-constant
         '(1 font-lock-variable-name-face))))

(put 'tpl-mode 'font-lock-defaults '(tpl-font-lock-keywords nil t))

(defun tpl-mode ()
  "Major mode for editing Google CTemplate file."
  (interactive)
  (kill-all-local-variables)
  (use-local-map tpl-mode-map)
  (setq major-mode 'tpl-mode)
  (setq mode-name "tpl-mode")
  (setq local-abbrev-table tpl-mode-abbrev-table)
  (setq indent-tabs-mode nil)
  (set-syntax-table tpl-mode-syntax-table)
  ;; show trailing whitespace, but only when the user can fix it
  (setq show-trailing-whitespace (not buffer-read-only))
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'tpl-indent)
  (setq font-lock-defaults '(tpl-mode-font-lock-keywords))
  (run-hooks 'tpl-mode-hook))

(provide 'tpl-mode)
