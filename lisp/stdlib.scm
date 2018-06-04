;;          Copyright Jean Pierre Cimalando 2018.
;; Distributed under the Boost Software License, Version 1.0.
;;    (See accompanying file LICENSE or copy at
;;          http://www.boost.org/LICENSE_1_0.txt)

(export
 ms:write
 ms:channel
 ms:velocity
 ms:set-channel!
 ms:set-velocity!
 ms:noteon
 ms:noteoff
 ms:control
 ms:pitch-bend
 ms:program
 ms:rpn
 ms:nrpn)

(define *channel* 0)
(define *velocity* 100)

(define (ensure-range val min max name)
  (unless (<= min val max)
    (error 'out-of-range "`~a` is expected to be in the range ~a..~a" name min max))
  val)

(define (ms:channel)
  *channel*)

(define (ms:velocity)
  *velocity*)

(define (ms:set-channel! channel)
  (ensure-range channel 0 15 "channel")
  (set! *channel* channel))

(define (ms:set-velocity! velocity)
  (ensure-range velocity 0 127 "velocity")
  (set! *velocity* velocity))

(define* (ms:noteon note #:key (channel *channel*) (velocity *velocity*))
  (ensure-range note 0 127 "note")
  (ensure-range channel 0 15 "channel")
  (ensure-range velocity 1 127 "velocity")
  (ms:write (vector (+ #x90 channel) note velocity)))

(define* (ms:noteoff note #:key (channel *channel*) (velocity *velocity*))
  (ensure-range note 0 127 "note")
  (ensure-range channel 0 15 "channel")
  (ensure-range velocity 0 127 "velocity")
  (ms:write (vector (+ #x80 channel) note velocity)))

(define* (ms:control ctrl value #:key (channel *channel*))
  (ensure-range ctrl 0 127 "control")
  (ensure-range channel 0 15 "channel")
  (ensure-range value 0 127 "value")
  (ms:write (vector (+ #xb0 channel) ctrl value)))

(define* (ms:pitch-bend value #:key (channel *channel*))
  (ensure-range value -8192 8191 "bend")
  (let* ((value (+ 8192 value))
         (lsb (modulo value 128))
         (msb (floor (/ value 128))))
    (ms:write (vector (+ #xe0 channel) lsb msb))))

(define* (ms:program pgm #:key (channel *channel*))
  (ensure-range pgm 0 127 "program")
  (ensure-range channel 0 15 "channel")
  (ms:write (vector (+ #xc0 channel) pgm)))

(define (combine-msb-lsb pair)
  (+ (ensure-range (cdr pair) 0 127 "lsb")
     (* 128 (ensure-range (car pair) 0 127 "msb"))))

(define* (ms:rpn rpn value #:key (channel *channel*))
  (cond
   ((pair? rpn) (ms:rpn (combine-msb-lsb rpn) value))
   ((pair? value) (ms:rpn rpn (combine-msb-lsb value)))
   (#t (ensure-range rpn 0 16383 "rpn")
       (ensure-range value 0 16383 "value")
       (ms:control 101 (floor (/ rpn 128)) #:channel channel)
       (ms:control 100 (modulo rpn 128) #:channel channel)
       (ms:control 6 (floor (/ value 128)) #:channel channel)
       (ms:control 38 (modulo value 128) #:channel channel)
       (ms:control 101 127 #:channel channel)
       (ms:control 100 127 #:channel channel))))

(define* (ms:nrpn rpn value #:key (channel *channel*))
  (cond
   ((pair? rpn) (ms:nrpn (combine-msb-lsb rpn) value))
   ((pair? value) (ms:nrpn rpn (combine-msb-lsb value)))
   (#t (ensure-range rpn 0 16383 "rpn")
       (ensure-range value 0 16383 "value")
       (ms:control 99 (floor (/ rpn 128)) #:channel channel)
       (ms:control 98 (modulo rpn 128) #:channel channel)
       (ms:control 6 (floor (/ value 128)) #:channel channel)
       (ms:control 38 (modulo value 128) #:channel channel)
       (ms:control 99 127 #:channel channel)
       (ms:control 98 127 #:channel channel))))
