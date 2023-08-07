;;; firrtl-mode.el --- mode for working with FIRRTL files

;; Author: Schuyler Eldridge <schuyler.eldridge@ibm.com>
;; Maintainer: Schuyler Eldridge <schuyler.eldridge@ibm.com>
;; Created: April 20, 2017
;; URL: https://github.com/ibm/firrtl-mode
;; Keywords: languages, firrtl
;; Version: 0.3.1
;; Package-Requires: ((emacs "24.3"))

;; Copyright 2017-2019 IBM
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

(defcustom firrtl-tab-width 2
  "Width of a tab for FIRRTL HDL."
  :group 'firrtl
  :type '(integer))

;;; Actual Code
(defvar firrtl-primop
  '("add" "sub" "mul" "div" "rem" "lt" "leq" "gt" "geq" "eq" "neq" "pad"
    "asUInt" "asSInt" "asClock" "shl" "shr" "dshl" "dshr" "cvt" "neg" "not"
    "and" "or" "xor" "andr" "orr" "xorr" "cat" "bits" "head" "tail"
    "asFixedPoint" "bpshl" "bpshr" "bpset" "mux" "validif" "read" "read"
    "force" "force_initial" "release" "release_initial" "assert" "assume"
    "cover" "asAsyncReset" "probe" "rwprobe"))
(defvar firrtl-type
  '("input" "output" "wire" "reg" "regreset" "node" "Clock" "Analog" "parameter"
    "UInt" "SInt" "Reset" "AsyncReset" "Integer" "String" "Path" "Probe"
    "RWProbe"))
(defvar firrtl-keyword
  '("circuit" "module" "extmodule" "intmodule" "declgroup" "class" "when" "else"
    "skip" "flip" "is invalid" "with" "printf" "stop" "inst" "of" "defname"
    "connect" "invalidate" "define" "propassign" "const" "group" "intrinsic" "cmem"
    "smem" "read mport" "write mport" "infer mport" "mem" "data-type" "depth"
    "read-latency" "write-latency" "reader" "writer" "read-under-write" "type"))

(defvar firrtl-primop-regexp
  (mapconcat 'identity
             (list "\s*\\("
                   (mapconcat 'identity firrtl-primop "\\|")
                   "\\)(")
             ""))
(defvar firrtl-type-regexp (regexp-opt firrtl-type 'words))
(defvar firrtl-keyword-regexp (regexp-opt firrtl-keyword 'words))

(defvar firrtl-font-lock-keywords
  `(;; Version information
    ("\\(FIRRTL version [0-9]+\.[0-9]+\.[0-9]+\\)"
     (1 font-lock-comment-face))
    ;; Circuit, module declarations
    ("\\(circuit\\|\\(ext\\|int\\)?module\\|declgroup\\|class\\|type\\)\\s-+\\(\\sw+\\)"
     (3 font-lock-function-name-face))
    ;; Literals
    ("\\(\\(U\\|S\\)Int<[0-9]+>\\)\\(.+?\\)?"
     (1 font-lock-type-face))
    ;; Indices and numbers (for a firrtl-syntax feel)
    ("[ \\[(]\\([0-9]+\\)"
     (1 font-lock-string-face))
    ;; Assignment operators
    (,firrtl-keyword-regexp . font-lock-keyword-face)
    ("\\(<[=-]\\|reset\s*=>\\)"
     (1, font-lock-keyword-face))
    ;; PrimOps
    (,firrtl-primop-regexp
     (1 font-lock-keyword-face))
    ;; Types
    (,firrtl-type-regexp . font-lock-type-face)
    ;; Variable declarations
    ("\\(input\\|output\\|wire\\|reg\\|regreset\\|node\\|parameter\\|[cs]?mem\\|mport\\)\s+\\([`A-Za-z0-9_]+\\)"
     (2 font-lock-variable-name-face))
    ("inst\s+\\([A-Za-z0-9_]+\\)\s+of\s+\\([A-Za-z0-9_]+\\)"
     (1 font-lock-variable-name-face)
     (2 font-lock-type-face))
    ("group\s+\\([A-Za-z0-9_]+\\)"
     (1 font-lock-type-face))
    ))

;; Indentation
(defun firrtl-possible-indentations ()
  "Determine all possible indentations for a given line."
  (beginning-of-line)
  (let (indents)
    (cond ((or (bobp) (looking-at "\s*circuit"))
           (setq indents (list 0)))
          ((looking-at "\s*\\(ext\\|int\\)?module")
           (setq indents (list tab-width)))
          ((looking-at "\s*;")
           (setq indents (number-sequence 0 (current-indentation) tab-width)))
          (t
           (save-excursion
             (backward-word)
             (beginning-of-line)
             (cond ((bobp)
                    (setq indents (list 0)))
                   ((looking-at "\s*circuit")
                    (setq indents (list tab-width)))
                   ((looking-at "\s*\\(\\(ext\\|int\\)?module\\|type\\)")
                    (setq indents (list (* 2 tab-width))))
                   ((looking-at "\s*\\(when\\|else\\|group\\|\\(mem\s+[A-Za-z0-9_]+\\)\\)")
                    (setq indents (number-sequence
                                   (* 2 tab-width)
                                   (+ (current-indentation) tab-width)
                                   tab-width)))
                   ((looking-at "\s*declgroup")
                    (setq indents (number-sequence
                                   tab-width
                                   (+ (current-indentation) tab-width)
                                   tab-width)))
                   (t
                    (setq indents (number-sequence
                                   (* 2 tab-width)
                                   (current-indentation)
                                   tab-width)))))))
    indents
    ))

(defvar firrtl--indents)
(defun firrtl-cycle-indents ()
  "Indent the current FIRRTL line.
Uses 'firrtl-possible-indentations' to determine all possible
indentations for the given line and then cycles through these on
repeated key presses."
  (interactive)
  (if (eq last-command 'indent-for-tab-command)
      (setq firrtl--indents (append (last firrtl--indents)
                                    (butlast firrtl--indents)))
    (setq firrtl--indents (firrtl-possible-indentations)))
  (indent-line-to (car (last firrtl--indents))))

(defvar firrtl-table
  (let ((table (make-syntax-table text-mode-syntax-table)))
    (modify-syntax-entry ?\; "<" table)
    (modify-syntax-entry ?\n ">" table)
    (modify-syntax-entry ?@ ". 1b" table)
    (modify-syntax-entry ?\[ ". 2b" table)
    (modify-syntax-entry ?\] "> b" table)
    (modify-syntax-entry ?\{ "(}" table)
    (modify-syntax-entry ?\} "){" table)
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?_ "w" table)
    (modify-syntax-entry ?\\ "\\" table)
    (modify-syntax-entry ?\" "|" table)
    table))

;;;###autoload
(define-derived-mode firrtl-mode text-mode "FIRRTL"
  "Major mode for editing FIRRTL (Flexible Intermediate Representation of RTL)."
  (when firrtl-tab-width
    (setq tab-width firrtl-tab-width)) ;; Defined FIRRTL tab width

  ;; Set everything up
  (setq font-lock-defaults '(firrtl-font-lock-keywords))
  (setq indent-tabs-mode nil)
  (setq-local indent-line-function 'firrtl-cycle-indents)
  (set-syntax-table firrtl-table)
  (setq-local comment-start ";")
  )

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.fir\\'" . firrtl-mode))

(provide 'firrtl-mode)
;;; firrtl-mode.el ends here
