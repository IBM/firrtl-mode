;;; firrtl-mode.el --- mode for working with FIRRTL files

;; Author: Schuyler Eldridge <schuyler.eldridge@ibm.com>
;; Maintainer: Schuyler Eldridge <schuyler.eldridge@ibm.com>
;; Created: April 20, 2017
;; URL: https://github.com/ibm/firrtl-mode
;; Keywords: languages, firrtl
;; Version: 0.2
;; Package-Requires: ((emacs "24.3"))

;; Copyright 2018 IBM
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;   http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

;;; Commentary:

;; A major mode for editing FIRRTL files currently providing syntax
;; highlighting and indentation.

;;; Code:

;;; Customization
(defgroup firrtl nil
  "Configuration for firrtl-mode."
  :prefix "firrtl-"
  :group 'wp
  :link '(url-link "https://github.com/ibm/firrtl-mode"))

(defcustom firrtl-mode-tab-width 2
  "Width of a tab for FIRRTL HDL."
  :group 'firrtl-mode
  :type '(integer))

;;; Actual Code
(defvar firrtl-primop
  '("add" "sub" "mul" "div" "mod"
    "eq" "neq" "geq" "gt" "leq" "lt"
    "dshl" "dshr" "shl" "shr"
    "not" "and" "or" "xor" "andr" "orr" "xorr"
    "neg" "cvt"
    "asUInt" "asSInt" "asClock"
    "pad" "cat" "bits" "head" "tail"
    "mux" "validif"))
(defvar firrtl-type
  '("input" "output"
    "wire" "reg" "node"
    "Clock" "Analog"))
(defvar firrtl-keyword
  '("when"
    "flip"
    "skip"
    "is invalid" "with"
    "printf" "stop"
    "inst" "of"))

(defvar firrtl-primop-regexp
  (mapconcat 'identity
             (list "=\s*\\("
                   (mapconcat 'identity firrtl-primop "\\|")
                   "\\)(")
             ""))
(defvar firrtl-type-regexp (regexp-opt firrtl-type 'words))
(defvar firrtl-keyword-regexp (regexp-opt firrtl-keyword 'words))

(defvar firrtl-font-lock-keywords
  `(;; Circuit, module declarations
    ("\\(circuit\\|\\(ext\\)?module\\)\\s-+\\([^ =:;([]+\\)\\s-+:"
     (1 font-lock-keyword-face)
     (3 font-lock-function-name-face))
    ;; Literals
    ("\\(\\(U\\|S\\)Int<[0-9]+>\\)\\(.+?\\)?"
     (1 font-lock-type-face))
    ;; Strings
    ("\\(\".+?\"\\)"
     (1, font-lock-string-face))
    ;; Comments, info
    ("\\(;\\|@\\)\\(.*\\)$"
     (1 font-lock-comment-delimiter-face)
     (2 font-lock-comment-face))
    ;; Indices and numbers (for a firrtl-syntax feel)
    ("[ \\[(]\\([0-9]+\\)"
     (1 font-lock-string-face))
    ;; Keywords
    (,firrtl-keyword-regexp . font-lock-keyword-face)
    ("\\(<[=-]\\)"
     (1, font-lock-keyword-face))
    ("\\(reset =>\\)"
     (1, font-lock-keyword-face))
    ;; PrimOps
    (,firrtl-primop-regexp
     (1 font-lock-keyword-face))
    ;; Types
    (,firrtl-type-regexp . font-lock-type-face)
    ;; Variable declarations
    ("\\(input\\|output\\|wire\\|reg\\|node\\)\s+\\([A-Za-z0-9_]+\\)"
     (2 font-lock-variable-name-face))
    ("inst\s+\\([A-Za-z0-9_]+\\)\s+of\s+\\([A-Za-z0-9_]+\\)"
     (1 font-lock-variable-name-face)
     (2 font-lock-type-face))
    ))

;; Indentation
(defun firrtl-mode-indent-line ()
  "Indent the current FIRRTL line."
  (interactive)
  (beginning-of-line)
  (let ((not-indented t) (cur-indent))
    (cond ((bobp)
           (setq cur-indent 0))
          ((looking-at "^\s*circuit")
           (setq cur-indent 0))
          ((looking-at "^\s*module")
           (setq cur-indent tab-width))
          (t
           (save-excursion
             (backward-word)
             (beginning-of-line)
             (cond ((looking-at "^\s*circuit")
                    (setq cur-indent (+ (current-indentation) tab-width)))
                   ((looking-at "^\s*module")
                    (setq cur-indent (+ (current-indentation) tab-width)))
                   (t
                    (setq cur-indent (* 2 tab-width)))))))
    (indent-line-to cur-indent)
    ))

;;;###autoload
(define-derived-mode firrtl-mode text-mode "FIRRTL mode"
  "Major mode for editing FIRRTL (Flexible Intermediate Representation of RTL)."
  (when firrtl-mode-tab-width
    (setq tab-width firrtl-mode-tab-width)) ;; Defined FIRRTL tab width

  ;; Set everything up
  (setq font-lock-defaults '(firrtl-font-lock-keywords))
  (setq-local indent-line-function 'firrtl-mode-indent-line)
  (setq comment-start ";")
  )

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.fir$" . firrtl-mode))

(provide 'firrtl-mode)
;;; firrtl-mode.el ends here
