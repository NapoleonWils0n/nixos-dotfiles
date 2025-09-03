;;; combobulate-c.el --- C mode support for Combobulate  -*- lexical-binding: t; -*-

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
;; Combobulate support for C based on tree-sitter.

;;; Code:

(require 'combobulate-settings)
(require 'combobulate-navigation)
(require 'combobulate-manipulation)
(require 'combobulate-interface)
(require 'combobulate-rules)
(require 'combobulate-setup)

(defun combobulate-c-pretty-print-node-name (node default-name)
  "Pretty print the node name for C mode."
  (pcase (combobulate-node-type node)
    ("function_definition"
     (let* ((name-node (combobulate-node-child-by-field node "declarator"))
            (name (if name-node (combobulate-node-text name-node) "function")))
       (combobulate-string-truncate (replace-regexp-in-string (rx "[(].*") "" name))))
    (t (combobulate-string-truncate default-name))))

(defvar combobulate-c-definitions
  '((context-nodes
     '("identifier" "string_literal" "declaration" "preproc_call"))
    (pretty-print-node-name-function #'combobulate-c-pretty-print-node-name)
    (procedures-sexp
     '((:activation-nodes
        ((:nodes ("function_definition" "if_statement" "for_statement" "while_statement" "do_statement"))))))
    (procedures-defun
     '((:activation-nodes
        ((:nodes ("function_definition"))))))
    (procedures-sibling
     '((:activation-nodes
        ((:nodes
          ((rule "source_file"))
          :position at
          :has-parent nil))
        :selector (:match-children t))
       (:activation-nodes
        ((:nodes
          ((rule "compound_statement"))
          :position at
          :has-parent ((rule "function_definition"))))
        :selector (:choose parent :match-children t))
       (:activation-nodes
        ((:nodes
          ((rule "declaration") (rule "expression_statement"))
          :has-parent ((rule "compound_statement"))))
        :selector (:choose parent :match-children t))
       ))
    (procedures-hierarchy
     '((:activation-nodes
        ((:nodes (exclude (all) "string") :position at))
        :selector (:choose node :match-children t))))
    (procedures-logical
     '((:activation-nodes
        ((:nodes ("and" "or") :position at))
        :selector (:choose parent :match-children t))))
    )
  "Configuration for `c-ts-mode' and C.")

(define-combobulate-language
 :name c
 :language c
 :major-modes (c-mode c-ts-mode)
 :custom combobulate-c-definitions
 :setup-fn combobulate-c-setup)

(defun combobulate-c-setup (_))

(provide 'combobulate-c)
;;; combobulate-c.el ends here
