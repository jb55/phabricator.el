
(require 'url)
(require 'json)

(defcustom phabricator-url "https://secure.phabricator.com/"
  "*Phabricator url"
  :group 'phabricator)

(defcustom phabricator-api-token "api-jadhsflajhsdfalksdjhf"
  "*Phabricator conduit api key"
  :group 'phabricator)

(defun phabricator-conduit-url (method args)
  (format (concat phabricator-url "api/%s?api.token=%s&%s")
          method
          phabricator-api-token
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

(defun phabricator-maniphest-query (query)
  (let ((results (phabricator-conduit-call "maniphest.query"
                                           (concat "fullText=" query
                                                   "&limit=10")))
        (formatter (lambda (task)
                     (cons (format-task-for-display task) task))))
    (mapcar formatter results)))

(defun phabricator-open-taskid-in-browser (taskid)
  (browse-url (concat phabricator-url "T" taskid)))

(defun phabricator-open-task-in-browser (task)
  (phabricator-open-taskid-in-browser (alist-get '(id) task)))
