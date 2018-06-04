;;          Copyright Jean Pierre Cimalando 2018.
;; Distributed under the Boost Software License, Version 1.0.
;;    (See accompanying file LICENSE or copy at
;;          http://www.boost.org/LICENSE_1_0.txt)

(export
 sy77:change-wpbr)

(define* (sy77:change-wpbr value #:key (id *device-identifier*))
  (xg:parameter-change #x020000
                       (vector #x28 #x00 (ensure-range value 0 127 "value"))
                       #:id id #:model #x34))
