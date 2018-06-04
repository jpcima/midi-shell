;;          Copyright Jean Pierre Cimalando 2018.
;; Distributed under the Boost Software License, Version 1.0.
;;    (See accompanying file LICENSE or copy at
;;          http://www.boost.org/LICENSE_1_0.txt)

(export
 xg:system-on)

(define* (xg:system-on #:key (id *device-identifier*))
  (ms:write (vector #xf0 #x43
                    id
                    #x4c
                    #x00 #x00 #x7e
                    #x00
                    #xf7)))
