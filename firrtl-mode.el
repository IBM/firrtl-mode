;; See LICENSE.IBM for license details

(setq firrtl-primop '("add" "sub" "mul" "div" "mod"
                       "eq" "neq" "geq" "gt" "leq" "lt"
                       "dshl" "dshr" "shl" "shr"
                       "not" "and" "or" "xor" "andr" "orr" "xorr"
                       "neg" "cvt"
                       "asUInt" "asSInt" "asClock"
                       "pad" "cat" "bits" "head" "tail"
                       "mux" "validif"))
(setq firrtl-keyword '("circuit" "module"
                       "input" "output"
                       "wire" "reg" "node"
                       "flip"
                       "is invalid"))
(setq firrtl-sim '("printf" "stop"))

(setq firrtl-primop-regexp (regexp-opt firrtl-primop 'words))
(setq firrtl-keyword-regexp (regexp-opt firrtl-keyword 'words))

(setq firrtl-font-lock-keywords
      `(;; Circuit, module declarations
        ("\\(circuit\\|module\\)\\s-+\\([^ =:;([]+\\)\\s-+:"
         (1 font-lock-keyword-face)
         (2 font-lock-function-name-face))
        ("\\(circuit\\|module\\)"
         (1 font-lock-keyword-face))
        ;; Literals
        ("\\(\\(U\\|S\\)Int<[0-9]+>\\)\\(.+?\\)"
         (1 font-lock-builtin-face))
        ;; Sized UInt, SInt
        ;; ("\\(\\(U\\|S\\)Int<[0-9]+>\\)"
        ;;  (1 font-lock-builtin-face))
        ;; Strings
        ("\\(\".+?\"\\)"
         (1, font-lock-string-face))
        ;; Comments and annotations
        ("\\(\\(;\\|@\\).+$\\)"
         (1 font-lock-comment-face))
        (,firrtl-keyword-regexp . font-lock-type-face)
        (,firrtl-primop-regexp . font-lock-type-face)
        ;; Indices and numbers
        ("\\[\\([0-9]+\\)\\]"
         (1 font-lock-variable-name-face))
        ("\"h?[0-9]+\""
         (0 font-lock-variable-name-face))
        ))

(define-derived-mode firrtl-mode text-mode "FIRRTL mode"
  "Major mode for editing Flexible Intermediate Representation of RTL (FIRRTL)"
  (setq font-lock-defaults '(firrtl-font-lock-keywords))
  )

(setq firrtl-primop nil)
(setq firrtl-keyword nil)
(setq firrtl-sim nil)
(setq firrtl-primop-regexp nil)
(setq firrtl-keyword-regexp nil)

(provide 'firrtl-mode)
