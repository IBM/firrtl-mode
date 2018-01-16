;;; firrtl-mode.el --- mode for working with FIRRTL files

;; Author: Schuyler Eldridge <schuyler.eldridge@ibm.com>
;; URL: https://github.com/ibm/firrtl-mode
;; Keywords: languages, firrtl
;; Version: 0

;; Copyright 2018 IBM
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;   http://www.apache.org/licenses/LICENSE-2.0

;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

;;; Commentary:

;; A major mode for editing FIRRTL files currently only providing
;; syntax highlighting.
;;
;;   - FIRRTL: https://github.com/freechipsproject/firrtl

;;; Code:

(defvar firrtl-primop)
(defvar firrtl-type)
(defvar firrtl-keyword)
(setq firrtl-primop
      '("add" "sub" "mul" "div" "mod"
        "eq" "neq" "geq" "gt" "leq" "lt"
        "dshl" "dshr" "shl" "shr"
        "not" "and" "or" "xor" "andr" "orr" "xorr"
        "neg" "cvt"
        "asUInt" "asSInt" "asClock"
        "pad" "cat" "bits" "head" "tail"
        "mux" "validif"))
(setq firrtl-type
      '("input" "output"
        "wire" "reg" "node"
        "Clock" "Analog"))
(setq firrtl-keyword
      '("when"
        "flip"
        "skip"
        "is invalid" "with"
        "printf" "stop"
        "inst" "of"))

(defvar firrtl-primop-regexp)
(defvar firrtl-type-regexp)
(defvar firrtl-keyword-regexp)
(defvar firrtl-font-lock-keywords)
(setq firrtl-primop-regexp
      (mapconcat 'identity
                 (list "=\s*\\("
                       (mapconcat 'identity firrtl-primop "\\|")
                       "\\)(")
                 ""))
(setq firrtl-type-regexp (regexp-opt firrtl-type 'words))
(setq firrtl-keyword-regexp (regexp-opt firrtl-keyword 'words))

(setq firrtl-font-lock-keywords
      `(;; Circuit, module declarations
        ("\\(circuit\\|module\\)\\s-+\\([^ =:;([]+\\)\\s-+:"
         (1 font-lock-keyword-face)
         (2 font-lock-function-name-face))
        ;; Literals
        ("\\(\\(U\\|S\\)Int<[0-9]+>\\)\\(.+?\\)?"
         (1 font-lock-type-face))
        ;; Strings
        ("\\(\".+?\"\\)"
         (1, font-lock-string-face))
        ;; Comments, source locators
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

(define-derived-mode firrtl-mode text-mode "FIRRTL mode"
  "Major mode for editing Flexible Intermediate Representation of RTL (FIRRTL)"
  (setq font-lock-defaults '(firrtl-font-lock-keywords))
  )

(setq firrtl-primop nil)
(setq firrtl-type nil)
(setq firrtl-keyword nil)
(setq firrtl-primop-regexp nil)
(setq firrtl-type-regexp nil)
(setq firrtl-keyword-regexp nil)

(add-to-list 'auto-mode-alist '("\\.fir$" . firrtl-mode))

(provide 'firrtl-mode)
;;; firrtl-mode.el ends here
