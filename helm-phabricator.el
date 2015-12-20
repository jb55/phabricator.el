
(require 'url)
(require 'json)

;; (defun call-conduit (host method)
;;   (interactive "P")
;;   )

;;; Code:

(defvar org-phabricator-url "https://phabricator.monstercat.com/")
(defvar org-phabricator-api-token "api-lqqx6yu5uqrhkek27ztoeuolhsrt")

(defun phabricator-conduit-url (method args)
  (format (concat org-phabricator-url "api/%s?api.token=%s&%s")
          method
          org-phabricator-api-token
          args))

;; (message (conduit-url "method" "args"))

(defun phabricator-conduit-call (method args)
  (mapcar 'cdr
          (alist-get '(result)
                     (with-current-buffer
                         (url-retrieve-synchronously
                          (phabricator-conduit-url method args))
                       (goto-char (+ 1 url-http-end-of-headers))
                       (json-read)))))

(defun format-task-for-display (task)
  (concat
   (alist-get '(objectName) task)
   ": "
   (alist-get '(title) task)))

(defun phabricator-maniphest-query (query)
  (let ((results (phabricator-conduit-call "maniphest.query"
                                           (concat "fullText=" query
                                                   "&limit=10")))
        (formatter (lambda (task)
                     (cons (format-task-for-display task) task))))
    (mapcar formatter results)))

(defun phabricator-open-taskid-in-browser (taskid)
  (browse-url (concat org-phabricator-url "T" taskid)))

(defun phabricator-open-task-in-browser (task)
  (phabricator-open-taskid-in-browser (alist-get '(id) task)))

(defvar helm-phabricator-maniphest-actions
  '(("Open Task in Browser" . phabricator-open-task-in-browser)))

(defun helm-phabricator-maniphest-query ()
  (phabricator-maniphest-query helm-pattern))

(defun helm-source-phabricator-maniphest ()
  (helm-build-sync-source "Maniphest"
    :candidates 'helm-phabricator-maniphest-query
    :action helm-phabricator-maniphest-actions
    :volatile t
    :requires-pattern 2
    :candidate-number-limit 9999))

(defun helm-phabricator-maniphest ()
  (interactive)
  (helm :sources `(,(helm-source-phabricator-maniphest))
        :buffer "*helm-maniphest*"))

(provide 'helm-phabricator-maniphest)
;;; org-phabricator.el ends here
