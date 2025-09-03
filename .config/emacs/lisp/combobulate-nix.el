;;; combobulate-nix.el --- Nix mode support for Combobulate  -*- lexical-binding: t; -*-

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

;; Combobulate support for Nix based on tree-sitter.

;;; Code:

(require 'combobulate-settings)
(require 'combobulate-navigation)
(require 'combobulate-manipulation)
(require 'combobulate-interface)
(require 'combobulate-rules)
(require 'combobulate-setup)


;; S-expression-like navigation for function bodies and `let` blocks.
(defvar combobulate-nix-procedures-sexp
  '((:activation-nodes
     ((:nodes ("lambda" "let_in_statement" "if_else_expression"))))
     :selector (:choose node))
  "Combobulate `procedures-sexp' for `nix'.")

;; Sibling-based navigation, for moving between top-level forms or attributes in a set.
(defvar combobulate-nix-procedures-sibling
  '((:activation-nodes
     ((:nodes
       ((rule "source_file"))
       :position at
       :has-parent nil))
     :selector (:match-children t))
    ;; Navigation inside a let_in_statement body
    (:activation-nodes
     ((:nodes
       ((rule "let_in_statement"))
       :position at
       :has-parent nil))
     :selector (:match-query (:query (let_in_statement (_) @match) :engine combobulate)))
    ;; Navigation inside a set
    (:activation-nodes
     ((:nodes
       ((rule "attr_set"))
       :position at))
     :selector (:match-children t))
    ;; Navigation between bindings in a set or let block
    (:activation-nodes
     ((:nodes ("binding") :position at :has-parent ("attr_set" "let_in_statement")))\
     :selector (:choose parent :match-children t)))
  "Combobulate `procedures-sibling' for `nix'.")

;; Hierarchical navigation, for moving up and down the syntax tree.
(defvar combobulate-nix-procedures-hierarchy
  '(;; General navigation
    (:activation-nodes
     ((:nodes (all) :position at))\
     :selector (:choose node :match-children t)))
  "Combobulate `procedures-hierarchy' for `nix'.")

;; Logical operators, for moving between `&&` and `||` parts of an expression.
(defvar combobulate-nix-procedures-logical
  '((:activation-nodes
     ((:nodes ("or_operator" "and_operator") :position at))
     :selector (:choose parent :match-children t)))
  "Combobulate `procedures-logical' for `nix'.")

;; Define what a `defun` is for navigation (e.g., M-a, M-e).
(defvar combobulate-nix-procedures-defun
  '((:activation-nodes
     ((:nodes ("lambda"))))
     :selector (:choose node))
  "Combobulate `procedures-defun' for `nix'.")

(defun combobulate-nix-pretty-print-node-name (node default-name)
  "Pretty-print the name of NODE."
  (pcase (combobulate-node-type node)
    ("lambda"
     (let* ((name-node (combobulate-node-child-by-field node "param"))
            (name (if name-node (combobulate-node-text name-node) "lambda")))
       (combobulate-string-truncate name)))
    ("inherit_expression"
     (let* ((name-node (combobulate-node-child-by-field node "attr_path"))
            (name (if name-node (combobulate-node-text name-node) "inherit")))
       (combobulate-string-truncate name)))
    ("binding"
     (let* ((name-node (combobulate-node-child-by-field node "attr_path"))
            (name (if name-node (combobulate-node-text name-node) "binding")))
       (combobulate-string-truncate name)))
    (_ default-name)))

(defvar combobulate-nix-definitions
  `((context-nodes
     '("string_escape" "string_content" "path"))
    (pretty-print-node-name-function #'combobulate-nix-pretty-print-node-name)
    (procedures-sexp . ,combobulate-nix-procedures-sexp)
    (procedures-sibling . ,combobulate-nix-procedures-sibling)
    (procedures-hierarchy . ,combobulate-nix-procedures-hierarchy)
    (procedures-logical . ,combobulate-nix-procedures-logical)
    (procedures-defun . ,combobulate-nix-procedures-defun)))

(defun combobulate-nix-setup (_))

(define-combobulate-language
 :name nix
 :language nix
 :major-modes (nix-mode nix-ts-mode)
 :custom combobulate-nix-definitions
 :setup-fn combobulate-nix-setup)

(provide 'combobulate-nix)
;;; combobulate-nix.el ends here
