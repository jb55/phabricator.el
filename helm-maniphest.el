
(load-file "phabricator.el")

;;; Code:
(defun format-task-for-display (task)
  (concat
   (alist-get '(objectName) task)
   ": "
   (alist-get '(title) task)))

(defvar helm-maniphest-actions
  '(("Open Task in Browser" . phabricator-open-task-in-browser)))

(defun helm-maniphest-query ()
  (phabricator-maniphest-query helm-pattern))

(defun helm-source-maniphest ()
  (helm-build-sync-source "Maniphest"
    :candidates 'helm-maniphest-query
    :action helm-maniphest-actions
    :volatile t
    :requires-pattern 2
    :candidate-number-limit 9999))

(defun helm-maniphest ()
  (interactive)
  (helm :sources `(,(helm-source-maniphest))
        :buffer "*helm-maniphest*"))

(provide 'helm-maniphest)
;;; helm-maniphest.el ends here
