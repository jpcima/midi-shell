;;          Copyright Jean Pierre Cimalando 2018.
;; Distributed under the Boost Software License, Version 1.0.
;;    (See accompanying file LICENSE or copy at
;;          http://www.boost.org/LICENSE_1_0.txt)

(export
 syx:device-identifier
 syx:set-device-identifier!)

(define *device-identifier* #x10)

(define (syx:device-identifier)
  *device-identifier*)

(define (syx:set-device-identifier! id)
  (ensure-range velocity 0 127 "id")
  (set! *device-identifier* id))
