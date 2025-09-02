;;; combobulate-bash.el --- Bash mode support for Combobulate  -*- lexical-binding: t; -*-

(require 'combobulate)

;; S-expression-like navigation for function bodies and conditionals.
(defvar combobulate-bash-procedures-sexp
  '((:activation-nodes
     ((:nodes ("function_definition" "if_statement" "for_statement" "while_statement")))))
  "Combobulate `procedures-sexp' for `bash'.")

;; Sibling-based navigation, typically for moving between statements.
(defvar combobulate-bash-procedures-sibling
  '(;; General navigation at the file level
    (:activation-nodes
     ((:nodes
       ((rule "source_file"))
       :position at
       :has-parent nil))
     :selector (:match-children t))
    ;; Statement-level navigation inside a compound statement
    (:activation-nodes
     ((:nodes
       ((rule "compound_statement"))
       :position at
       :has-parent ((rule "function_definition"))))
     :selector (:choose parent :match-children t)))
  "Combobulate `procedures-sibling' for `bash'.")

;; Hierarchical navigation, for moving up and down the syntax tree.
(defvar combobulate-bash-procedures-hierarchy
  '(;; General navigation
    (:activation-nodes
     ((:nodes (exclude (all) "string") :position at))
     :selector (:choose node :match-children t)))
  "Combobulate `procedures-hierarchy' for `bash'.")

;; Logical operators, for moving between `&&` and `||` parts of a command.
;; This has been corrected to use the proper list structure.
(defvar combobulate-bash-procedures-logical
  '((:activation-nodes
     ((:nodes ("and" "or") :position at))
     :selector (:choose parent :match-children t)))
  "Combobulate `procedures-logical' for `bash'.")

(defun combobulate-bash-setup (_)
  "Setup function for `bash-ts-mode'."
  (add-hook 'sh-mode-hook
            (lambda ()
              (when (treesit-ready-p 'bash)
                (combobulate-mode)))))

(define-combobulate-language
 :name bash
 :language bash
 :major-modes (sh-mode bash-ts-mode)
 :setup-fn combobulate-bash-setup)

(provide 'combobulate-bash)

;;; combobulate-bash.el ends here
