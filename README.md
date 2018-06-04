# midi-shell
Scheme REPL for sending MIDI commands

(**ms:channel**)

(**ms:velocity**)

(**ms:set-channel!** *channel*)

(**ms:set-velocity!** *velocity*)

(**ms:noteon** *note* #:key *channel* *velocity*)

(**ms:noteoff** *note* #:key *channel* *velocity*)

(**ms:control** *ctrl* *value* #:key *channel*)

(**ms:pitch-bend** *value* #:key *channel*)

(**ms:program** *pgm* #:key *channel*)

(**ms:rpn** *rpn* *value* #:key *channel*)

(**ms:nrpn** *rpn* *value* #:key *channel*)

## Enabling completion

Put this in `~/.midi-shell-rc`.

```
(use-modules (ice-9 readline))
(activate-readline)
```
