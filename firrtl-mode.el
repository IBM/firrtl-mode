;; See LICENSE.IBM for license details

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
      '("flip"
        "skip"
        "is invalid"
        "printf" "stop"))

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
        ("\\(circuit\\|module\\)"
         (1 font-lock-keyword-face))
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
        ;; Indices and numbers
        ("[ \\[]\\([0-9]+\\)"
         (1 font-lock-variable-name-face))
        ("\"h?[0-9]+\""
         (0 font-lock-variable-name-face))
        ;; Keywords
        (,firrtl-keyword-regexp . font-lock-type-face)
        ;; PrimOps
        (,firrtl-primop-regexp
         (1 font-lock-keyword-face))
        ;; Types
        (,firrtl-type-regexp . font-lock-type-face)
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
