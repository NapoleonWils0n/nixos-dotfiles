;;; combobulate-elisp.el --- Elisp mode support for Combobulate  -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Your Name

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

(require 'combobulate-settings)
(require 'combobulate-navigation)
(require 'combobulate-manipulation)
(require 'combobulate-interface)
(require 'combobulate-rules)
(require 'combobulate-setup)

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
    ;; Navigation inside a function or expression body
    (:activation-nodes
     ((:nodes
       ((rule "body"))
       :position at
       :has-parent ((rule "function-definition" "lambda"))))
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
     ((:nodes ("and" "or") :position at))
     :selector (:choose parent :match-children t)))
  "Combobulate `procedures-logical' for `elisp'.")

;; Define what a `defun` is for navigation (e.g., M-a, M-e).
(defvar combobulate-elisp-procedures-defun
  '((:activation-nodes
     ((:nodes ("function-definition")))))
  "Combobulate `procedures-defun' for `elisp'.")

(defun combobulate-elisp-setup (_))

(define-combobulate-language
  :name elisp
  :language elisp
  :major-modes (emacs-lisp-mode lisp-mode elisp-ts-mode)
  :setup-fn combobulate-elisp-setup)

(provide 'combobulate-elisp)

;;; combobulate-elisp.el ends here
