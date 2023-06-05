(require 'org-noter-test-utils)
(require 'org-noter-org-roam)

(describe "org-noter-core"
          (before-each
           (create-org-noter-test-session)
           )

          (describe "org-roam"
                    (before-each
                     ;; org-noter uses file-equal-p that looks at the filesystem. We need real files to verify this functionality.
                     (shell-command "mkdir -p /tmp/pubs/ && touch /tmp/pubs/solove-nothing-to-hide.pdf && touch /tmp/test.pdf"))

                    (describe "top level heading insertion"
                              (it "can insert a top level heading at the end of the file"
                                  (with-mock-contents
                                   mock-contents-simple-notes-file
                                   '(lambda ()
                                      (org-noter--create-notes-heading "ADOCUMENT" "/tmp/file")
                                      (expect (string-match "ADOCUMENT" (buffer-string))  :not :to-be nil)
                                      (expect (string-match "/tmp/file" (buffer-string))  :not :to-be nil)
                                      ;; ADOCUMENT should come after solove-nothing-to-hide
                                      (expect (string-match "solove-nothing-to-hide" (buffer-string)) :to-be-less-than
                                              (string-match "ADOCUMENT" (buffer-string)))
                                      (message (buffer-string)))))

                              (it "can find an existing heading without creating a new one"
                                  (with-mock-contents
                                   mock-contents-simple-notes-file
                                   '(lambda ()
                                      (let* ((found-heading-pos (org-noter--find-create-top-level-heading-for-doc "/tmp/test.pdf" "solove-nothing-to-hide")))
                                      (message "\n00 ----")
                                      (goto-char found-heading-pos)
                                      (insert "!!")
                                      (message (buffer-string))
                                      (message "\n00 ----")

                                      (expect found-heading-pos :to-be 141)
                                      (message "----")
                                      (message (buffer-string))
                                      (message "---- %s" (length (buffer-string)))))))


                              (it "can create a new heading"
                                  (with-mock-contents
                                   mock-contents-simple-notes-file
                                   '(lambda ()
                                      (expect
                                       ;; org-noter-test-file is defined in test-utils.
                                       (org-noter--find-create-top-level-heading-for-doc "/tmp/some-other-pdf-file.pdf" "SOME HEADING")
                                       :to-be 162)
                                      (message "----")
                                      (message (buffer-string))
                                      (message "---- %s" (length (buffer-string)))

                                      )))
                              )


                    (describe "identifying top level headlines"
                              (before-each
                               ;; org-noter uses file-equal-p that looks at the filesystem. We need real files to verify this functionality.
                               (shell-command "mkdir -p /tmp/pubs/ && touch /tmp/pubs/solove-nothing-to-hide.pdf")
                               )

                              (it "can find the top level headline for a specified document and return the position"
                                  (with-mock-contents
                                   mock-contents-simple-notes-file
                                   '(lambda ()
                                      (message "\n11 ----")
                                      (insert "!!")
                                      (message (buffer-string))
                                      (message "\n11 ----")
                                      (expect
                                       (org-noter--find-top-level-heading-for-document-path "/tmp/test.pdf")
                                       :to-be 143)
                                      (message (buffer-string)))))


                              (it "return nil for a non existent top level heading"
                                  (with-mock-contents
                                   mock-contents-simple-notes-file
                                   '(lambda ()
                                      (expect
                                       (org-noter--find-top-level-heading-for-document-path "/FAKE/PATH/DOESNT/EXIST")
                                       :to-be nil)
                                      (message (buffer-string)))))
                              )




                    )






)
