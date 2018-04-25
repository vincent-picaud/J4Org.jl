;; [[file:~/GitHub/J4Org.jl/docs/main.org::*Emacs%20configuration][Emacs configuration:1]]
(package-initialize)

(require 'ess-site)
;; if required
;; (setq  inferior-julia-program-name "/path/to/julia-release-basic")

(require 'org)
;; *replace me* with your own ob-julia.el file location 
(add-to-list 'load-path "~/GitLab/WorkingWithOrgMode/EmacsFiles")
;; babel configuration
(setq org-confirm-babel-evaluate nil)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((julia . t)))
;; Emacs configuration:1 ends here
