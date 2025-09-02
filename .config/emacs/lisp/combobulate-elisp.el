;;; combobulate-elisp.el --- Elisp mode support for Combobulate  -*- lexical-binding: t; -*-

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

;; Combobulate support for Emacs Lisp based on tree-sitter.

;;; Code:

(require 'combobulate)

;; S-expression-like navigation, specifically for functions and expressions.
(defvar combobulate-elisp-procedures-sexp
  '((:activation-nodes
     ((:nodes ("call" "function-definition" "lambda"))))
     :selector (:choose node))
  "Combobulate `procedures-sexp' for `elisp'.")

;; Sibling-based navigation, for moving between top-level forms or statements within a body.
(defvar combobulate-elisp-procedures-sibling
  '(;; Navigation at the top-level of a file
    (:activation-nodes
     ((:nodes
       ((rule "source_file"))
       :position at
       :has-parent nil))
     :selector (:match-children t))
    ;; Navigation inside a function or a `progn` block.
    (:activation-nodes
     ((:nodes
       ((rule "function-body" "progn" "let" "let*"))
       :position at
       :has-parent ((rule "function-definition"))))
     :selector (:choose parent :match-children t)))
  "Combobulate `procedures-sibling' for `elisp'.")

;; Hierarchical navigation, for moving up and down the syntax tree.
(defvar combobulate-elisp-procedures-hierarchy
  '(;; General navigation
    (:activation-nodes
     ((:nodes (all) :position at))
     :selector (:choose node :match-children t)))
  "Combobulate `procedures-hierarchy' for `elisp'.")

;; Logical operators, for moving between the clauses of `and` or `or`.
(defvar combobulate-elisp-procedures-logical
  '((:activation-nodes
     ((:nodes ("and" "or") :position at))\
     :selector (:choose parent :match-children t)))
  "Combobulate `procedures-logical' for `elisp'.")

;; Define what a `defun` is for navigation (e.g., M-a, M-e).
(defvar combobulate-elisp-procedures-defun
  '((:activation-nodes
     ((:nodes ("function-definition")))))\
  "Combobulate `procedures-defun' for `elisp'.")

(defun combobulate-elisp-pretty-print-node-name (node default-name)
  "Pretty-print the name of NODE."
  (pcase (combobulate-node-type node)
    ("function-definition"
     (let* ((name-node (combobulate-node-child-by-field node "name"))
            (name (if name-node (combobulate-node-text name-node) "lambda")))
       (combobulate-string-truncate name)))
    (t default-name)))

(defun combobulate-elisp-setup (_)
  "Setup function for `elisp-ts-mode' and other Lisp modes."
  (add-hook 'emacs-lisp-mode-hook
            (lambda ()
              (when (treesit-ready-p 'elisp)
                (combobulate-mode))))
  (add-hook 'lisp-interaction-mode-hook
            (lambda ()
              (when (treesit-ready-p 'elisp)
                (combobulate-mode)))))

(define-combobulate-language
 :name elisp
 :language elisp
 :major-modes (emacs-lisp-mode lisp-interaction-mode)
 :pretty-print-node-name-function #'combobulate-elisp-pretty-print-node-name
 :setup-fn combobulate-elisp-setup)

(provide 'combobulate-elisp)

;;; combobulate-elisp.el ends here
