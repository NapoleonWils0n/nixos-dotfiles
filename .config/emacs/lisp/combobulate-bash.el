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
(defvar combobulate-bash-procedures-logical
  '((:activation-nodes
     ((:nodes ("and" "or") :position at))
     :selector (:choose parent :match-children t)))
  "Combobulate `procedures-logical' for `bash'.")

;; Define what a `defun` is for navigation (e.g., M-a, M-e).
(defvar combobulate-bash-procedures-defun
  '((:activation-nodes
     ((:nodes ("function_definition")))))
  "Combobulate `procedures-defun' for `bash'.")

(defun combobulate-bash-setup (_))

(define-combobulate-language
 :name bash
 :language bash
 :major-modes (sh-mode bash-ts-mode)
 :setup-fn combobulate-bash-setup)

(provide 'combobulate-bash)

;;; combobulate-bash.el ends here
