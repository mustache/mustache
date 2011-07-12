;;; mustache-mode.el --- A major mode for editing Mustache files.

;; Author: Tony Gentilcore
;;       Chris Wanstrath
;;       Daniel Hackney

;; Version: 1.2

;; This file is not part of Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; 1) Copy this file somewhere in your Emacs `load-path'.  To see what
;;    your `load-path' is, run inside emacs: C-h v load-path<RET>
;;
;; 2) Add the following to your .emacs file:
;;
;;    (require 'mustache-mode)

;; While the Mustache language can be used for any types of text,
;; this mode is intended for using Mustache to write HTML.

;;; Known Bugs:

;; The indentation still has minor bugs due to the fact that
;; templates do not require valid HTML.

;; It would be nice to be able to highlight attributes of HTML tags,
;; however this is difficult due to the presence of CTemplate symbols
;; embedded within attributes.

(eval-when-compile
  (require 'font-lock))

(defvar mustache-mode-version "1.2"
  "Version of `mustache-mode.el'.")

(defvar mustache-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-m" 'reindent-then-newline-and-indent)
    (define-key map "\C-ct" 'mustache-insert-tag)
    (define-key map "\C-cv" 'mustache-insert-variable)
    (define-key map "\C-cs" 'mustache-insert-section)
    map)
  "Keymap for mustache-mode major mode")

(defvar mustache-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?<  "(>  " st)
    (modify-syntax-entry ?>  ")<  " st)
    (modify-syntax-entry ?\" ".   " st)
    (modify-syntax-entry ?\\ ".   " st)
    (modify-syntax-entry ?'  "w   " st)
    st)
  "Syntax table in use in mustache-mode buffers.")

(defvar mustache-basic-offset 2
  "The basic indentation offset.")

;; Constant regular expressions to identify template elements.
(defconst mustache-mode-mustache-token "[a-zA-Z_.][a-zA-Z0-9_:=\?!.-]*?")
(defconst mustache-mode-section (concat "\\({{[#^/]\s*"
                                   mustache-mode-mustache-token
                                   "\s*}}\\)"))
(defconst mustache-mode-open-section (concat "\\({{#\s*"
                                        mustache-mode-mustache-token
                                        "\s*}}\\)"))
(defconst mustache-mode-close-section (concat "{{/\\(\s*"
                                         mustache-mode-mustache-token
                                         "\s*\\)}}"))
;; TODO(tonyg) Figure out a way to support multiline comments.
(defconst mustache-mode-comment "\\({{!.*?}}\\)")
(defconst mustache-mode-include (concat "\\({{[><]\s*"
                                   mustache-mode-mustache-token
                                   "\s*}}\\)"))
(defconst mustache-mode-variable (concat "\\({{\s*"
                                    mustache-mode-mustache-token
                                    "\s*}}\\)"))
(defconst mustache-mode-builtins
  (concat
   "\\({{\\<\s*"
   (regexp-opt
    '("BI_NEWLINE" "BI_SPACE")
    t)
   "\s*\\>}}\\)"))
(defconst mustache-mode-close-section-at-start (concat "^[ \t]*?"
                                                  mustache-mode-close-section))

;; Constant regular expressions to identify html tags.
;; Taken from HTML 4.01 / XHTML 1.0 Reference found at:
;; http://www.w3schools.com/tags/default.asp.
(defconst mustache-mode-html-constant "\\(&#?[a-z0-9]\\{2,5\\};\\)")
(defconst mustache-mode-pair-tag
  (concat
   "\\<"
   (regexp-opt
    '("a" "abbr" "acronym" "address" "applet" "area" "b" "bdo"
      "big" "blockquote" "body" "button" "caption" "center" "cite"
      "code" "col" "colgroup" "dd" "del" "dfn" "dif" "div" "dl"
      "dt" "em" "fieldset" "font" "form" "frame" "frameset" "h1"
      "header" "nav" "footer" "section"
      "h2" "h3" "h4" "h5" "h6" "head" "html" "i" "iframe" "ins"
      "kbd" "label" "legend" "li" "link" "map" "menu" "noframes"
      "noscript" "object" "ol" "optgroup" "option" "p" "pre" "q"
      "s" "samp" "script" "select" "small" "span" "strike"
      "strong" "style" "sub" "sup" "table" "tbody" "td" "textarea"
      "tfoot" "th" "thead" "title" "tr" "tt" "u" "ul" "var")
    t)
   "\\>"))
(defconst mustache-mode-standalone-tag
  (concat
   "\\<"
   (regexp-opt
    '("base" "br" "hr" "img" "input" "meta" "param")
    t)
   "\\>"))
(defconst mustache-mode-open-tag (concat "<\\("
                                    mustache-mode-pair-tag
                                    "\\)"))
(defconst mustache-mode-close-tag (concat "</\\("
                                     mustache-mode-pair-tag
                                     "\\)>"))
(defconst mustache-mode-close-tag-at-start (concat "^[ \t]*?"
                                              mustache-mode-close-tag))

(defconst mustache-mode-blank-line "^[ \t]*?$")
(defconst mustache-mode-dangling-open (concat "\\("
                                         mustache-mode-open-section
                                         "\\)\\|\\("
                                         mustache-mode-open-tag
                                         "\\)[^/]*$"))

(defun mustache-insert-tag (tag)
  "Inserts an HTML tag."
  (interactive "sTag: ")
  (mustache-indent)
  (insert (concat "<" tag ">"))
  (insert "\n\n")
  (insert (concat "</" tag ">"))
  (mustache-indent)
  (forward-line -1)
  (mustache-indent))

(defun mustache-insert-variable (variable)
  "Inserts a tpl variable."
  (interactive "sVariable: ")
  (insert (concat "{{" variable "}}")))

(defun mustache-insert-section (section)
  "Inserts a tpl section."
  (interactive "sSection: ")
  (mustache-indent)
  (insert (concat "{{#" section "}}\n"))
  (insert "\n")
  (insert (concat "{{/" section "}}"))
  (mustache-indent)
  (forward-line -1)
  (mustache-indent))

(defun mustache-indent ()
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
            (setq close-at-start mustache-mode-close-section-at-start
                  open-token "{{#")
          (setq close-at-start mustache-mode-close-tag-at-start
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
                     (and (not (bobp)) (looking-at mustache-mode-blank-line))))
            (setq cur-indent (current-indentation))
            (if (re-search-forward mustache-mode-dangling-open old-pnt t)
                (setq cur-indent (+ cur-indent mustache-basic-offset)))))
        ;; Finally, we execute the actual indentation.
        (if (> cur-indent 0)
            (indent-line-to cur-indent)
          (indent-line-to 0))))))

(defconst mustache-mode-font-lock-keywords
  `((,mustache-mode-section (1 font-lock-keyword-face))
    (,mustache-mode-comment (1 font-lock-comment-face))
    (,mustache-mode-include (1 font-lock-function-name-face))
    (,mustache-mode-builtins (1 font-lock-variable-name-face))
    (,mustache-mode-variable (1 font-lock-reference-face))
    (,(concat "</?\\(" mustache-mode-pair-tag "\\)") (1 font-lock-function-name-face))
    (,(concat "<\\(" mustache-mode-standalone-tag "\\)") (1 font-lock-function-name-face))
    (,mustache-mode-html-constant (1 font-lock-variable-name-face))))

;;;###autoload
(define-derived-mode mustache-mode fundamental-mode "Mustache"
  (set (make-local-variable 'indent-line-function) 'mustache-indent)
  (set (make-local-variable 'indent-tabs-mode) nil)
  (set (make-local-variable 'font-lock-defaults) '(mustache-mode-font-lock-keywords)))

(add-to-list 'auto-mode-alist '("\\.mustache$" . mustache-mode))

(provide 'mustache-mode)

;;; mustache-mode.el ends here
