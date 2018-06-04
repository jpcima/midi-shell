;;          Copyright Jean Pierre Cimalando 2018.
;; Distributed under the Boost Software License, Version 1.0.
;;    (See accompanying file LICENSE or copy at
;;          http://www.boost.org/LICENSE_1_0.txt)

(use-modules (srfi srfi-43))

(export
 xg:system-on
 xg:parameter-change
 xg:parameter-change/u7
 xg:parameter-change/u14)

(define* (xg:system-on #:key (id *device-identifier*))
  (ms:write (vector #xf0 #x43
                    id
                    #x4c
                    #x00 #x00 #x7e
                    #x00
                    #xf7)))

(define* (xg:parameter-change address data #:key (id *device-identifier*) (model #x4c))
  (ms:write
   (vector-append
    (vector #xf0 #x43
            id
            model
            (ensure-range (ash address -16) 0 127 "address[0]")
            (ensure-range (logand (ash address -8) #xff) 0 127 "address[1]")
            (ensure-range (logand address #xff) 0 127 "address[2]"))
    data
    (vector #xf7))))

(define* (xg:parameter-change/u7 address value #:key (id *device-identifier*) (model #x4c))
  (xg:parameter-change address
                       (vector (ensure-range value 0 127 "value"))
                       #:id id #:model model))

(define* (xg:parameter-change/u14 address value #:key (id *device-identifier*) (model #x4c))
  (xg:parameter-change address
                       (vector
                        (ensure-range (ash value -7) 0 127 "value")
                        (logand value #x7f))
                       #:id id #:model model))
