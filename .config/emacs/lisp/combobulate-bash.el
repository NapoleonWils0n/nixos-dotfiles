;;; combobulate-bash.el --- Bash mode support for Combobulate  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 NapoleonWils0n

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Combobulate support for Bash based on tree-sitter.

;;; Code:

(require 'combobulate-settings)
(require 'combobulate-navigation)
(require 'combobulate-manipulation)
(require 'combobulate-interface)
(require 'combobulate-rules)
(require 'combobulate-setup)

(defun combobulate-bash-pretty-print-node-name (node default-name)
  "Pretty print the node name for Bash mode."
  (pcase (combobulate-node-type node)
    ("command" (combobulate-string-truncate (combobulate-node-text node) 40))
    ("variable_name" (combobulate-string-truncate (combobulate-node-text node) 40))
    ("function_definition" (concat "def " (combobulate-node-text node)))
    (_ default-name)))

(eval-and-compile
  (defvar combobulate-bash-definitions
    '((pretty-print-node-name-function #'combobulate-bash-pretty-print-node-name)
      
      ;; This rule highlights keywords and node types in the query builder.
      (highlight-queries-default
       '(;; highlight keywords
         ((word) @hl.default)
         ;; highlight function definitions and commands
         ((function_definition) @hl.function)
         ((command) @hl.function)
         ;; highlight variables
         ((variable_name) @hl.variable)
         ;; highlight comments
         ((comment) @hl.comment)
         ))

      ;; S-expression-like navigation for function bodies and conditionals.
      (procedures-sexp
       '(:activation-nodes
         ((:nodes ((rule "function_definition") (rule "if_statement") (rule "for_statement") (rule "while_statement") (rule "case_statement"))))))
      
      ;; Sibling-based navigation, typically for moving between statements.
      (procedures-sibling
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
          :selector (:choose parent :match-children t))
         ;; Add this rule to enable sibling navigation in `case` statements
         (:activation-nodes
          ((:nodes ((rule "case_item"))))
          :selector (:choose node :match-siblings t)))
       )

      ;; Hierarchical navigation, for moving up and down the syntax tree.
      (procedures-hierarchy
       '(;; General navigation
         (:activation-nodes
          ((:nodes (exclude (all) (rule "string")) :position at))
          :selector (:choose node :match-children t)))
       )

      ;; Logical operators, for moving between `&&` and `||` parts of a command.
      (procedures-logical
       '((:activation-nodes
          ((:nodes ((rule "and") (rule "or")) :position at))
          :selector (:choose parent :match-children t)))
       )

      ;; Define what a `defun` is for navigation (e.g., M-a, M-e).
      (procedures-defun
       '((:activation-nodes
          ((:nodes ((rule "function_definition"))))))
       )
      
      (procedures-edit
       '((:activation-nodes
          ((:nodes ((rule "string") (rule "variable_name")) :position at))
          :selector (:choose node))))
      
      (procedures-copy
       '((:activation-nodes
          ((:nodes ((rule "command") (rule "function_definition") (rule "comment")) :position at))
          :selector (:choose node))))
      
      (procedures-cut
       '((:activation-nodes
          ((:nodes ((rule "command") (rule "function_definition") (rule "comment")) :position at))
          :selector (:choose node))))
      
      (procedures-delete
       '((:activation-nodes
          ((:nodes ((rule "command") (rule "function_definition") (rule "comment")) :position at))
          :selector (:choose node))))
      
      (procedures-query-builder
       '((:activation-nodes
          ((:nodes (all) :position at))
          :selector (:choose node))))
      ))
  "A combined variable for all Combobulate Bash definitions.")


(define-combobulate-language
 :name bash
 :language bash
 :major-modes (sh-mode bash-ts-mode)
 :custom combobulate-bash-definitions
 :setup-fn combobulate-bash-setup)

(defun combobulate-bash-setup (_))

(provide 'combobulate-bash)

;;; combobulate-bash.el ends here
