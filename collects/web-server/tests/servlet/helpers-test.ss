(module helpers-test mzscheme
  (require (planet "test.ss" ("schematics" "schemeunit.plt" 2))
           (lib "list.ss")
           (lib "url.ss" "net")
           (lib "response-structs.ss" "web-server" "private")
           (lib "request-structs.ss" "web-server" "private")
           (lib "helpers.ss" "web-server" "servlet"))
  (provide helpers-tests)
  
  (define helpers-tests
    (test-suite
     "Helpers"
     
     (test-suite
      "with-errors-to-browser"
      (test-case
       "Basic"
       (check-pred list? (with-errors-to-browser (lambda (x) x) (lambda () (error 'error "Hey!")))))
      (test-case
       "Basic (succ)"
       (check-true (with-errors-to-browser (lambda (x) x) (lambda () #t)))))
     
     ; XXX Test redirection status
     ; XXX Test optional headers
     (test-suite
      "redirect-to"
      (test-case
       "Basic"
       (check-pred response/full? (redirect-to "http://test.com/foo"))))
     
     (test-suite
      "redirection-status?"
      (test-case "permanently" (check-true (redirection-status? permanently)))
      (test-case "temporarily" (check-true (redirection-status? temporarily)))
      (test-case "see-other" (check-true (redirection-status? see-other))))
     
     (test-suite
      "request-bindings"
      (test-case
       "Simple"
       (check-equal? (request-bindings
                      (make-request 'get (string->url "http://test.com/foo")
                                    empty (list (make-binding:form #"key" #"val")) #f
                                    "host" 80 "client"))
                     '((key . "val"))))
      (test-case
       "Case"
       (check-equal? (request-bindings
                      (make-request 'get (string->url "http://test.com/foo")
                                    empty (list (make-binding:form #"KEY" #"val")) #f
                                    "host" 80 "client"))
                     '((key . "val"))))
      (test-case
       "Multi"
       (check-equal? (request-bindings
                      (make-request 'get (string->url "http://test.com/foo")
                                    empty (list (make-binding:form #"key" #"val")
                                                (make-binding:form #"key2" #"val")) #f
                                                                                    "host" 80 "client"))
                     '((key . "val")
                       (key2 . "val"))))
      (test-case
       "File"
       (check-equal? (request-bindings
                      (make-request 'get (string->url "http://test.com/foo")
                                    empty (list (make-binding:file #"key" #"file" #"val")) #f
                                    "host" 80 "client"))
                     '((key . #"val")))))
     
     (test-suite
      "request-headers"
      (test-case
       "Simple"
       (check-equal? (request-headers
                      (make-request 'get (string->url "http://test.com/foo")
                                    (list (make-header #"key" #"val")) empty #f
                                    "host" 80 "client"))
                     '((key . "val"))))
      (test-case
       "Case"
       (check-equal? (request-headers
                      (make-request 'get (string->url "http://test.com/foo")
                                    (list (make-header #"KEY" #"val")) empty #f
                                    "host" 80 "client"))
                     '((key . "val"))))))))