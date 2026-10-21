# From Raw Bytes to a Testable Tetrahedron

This walkthrough turns the ideas in the archived conversation into a public,
reproducible experiment. It does not ask the reader to accept the narrative as
proof. Each important claim is paired with a command, a test, or an explicit
boundary.

See [`chat-outline.md`](chat-outline.md) for the chronological source map from
the archived conversation to each claim and its current proof status.

The source conversation is retained in `_archive/_chat_history/` as historical
material. The executable shell scripts in this repository are the current
source of truth.

## 1. Start With Four Files

The first model has four vertices. Each vertex is a file treated as a raw byte
sequence. Four vertices have six unordered pairs:

```text
A-B  A-C  A-D  B-C  B-D  C-D
```

The analyzer is:

```sh
sh scripts/tetra-mask.sh FILE1 FILE2 FILE3 FILE4
```

For each edge it reports:

- both byte lengths
- whether the edge is comparable
- the number of differing bytes
- the number of differing bits
- an optional byte-wise XOR mask with `-v`

Unequal files are not padded or truncated. Their edge is reported as `not
comparable`.

## 2. Use Real Byte Data

The chat used three BusyBox inventory artifacts to demonstrate a reference
index structure. They are optional and can be regenerated on demand:

- `full`: path-qualified output from `busybox --list-full`
- `list`: applet names from `busybox --list`
- `full_list`: an annotated view with line numbers and control-character
  markers

They are reference-index outputs, not implementation source. Regenerate the
basic two-view frame with:

```sh
busybox --list-full > full; busybox --list > list; busybox cat -An full list > full_list
```

The test harness does not rewrite or normalize them, and skips the
artifact-specific check if they are absent from a checkout.

For an exploratory comparison:

```sh
sh scripts/tetra-mask.sh -v full list full_list README.md
```

Because these files have different lengths, the output should report six
non-comparable edges. That is expected behavior, not a failed comparison.

The original shell pipeline used `diff -y`. BusyBox `diff` does not implement
that option, so the portable analyzer performs the raw-byte comparison directly
and keeps display transformations separate from measurement.

## 3. Verify the Small Fixture

The regular test command creates four temporary files containing ordinary,
zero, and high-bit bytes:

```sh
busybox ash tests/run.sh
```

The fixture checks known XOR masks, bit counts, and unequal-file handling. A
successful run begins with:

```text
PASS: tetra-mask control-byte fixtures
PASS: unequal raw-byte vertices are not compared
```

This is the smallest complete demonstration of the tetrahedron model.

For a first-principles check that does not reuse the analyzer's arithmetic, run
the literal template checker against a deliberately defined claim file:

```sh
busybox ash tests/probe-literals.sh path/to/tagged-claims.txt
```

It accepts only tagged binary records with fixed-width regular expressions. The
checker validates tags and widths, not the derivation or meaning of a claim.

## 4. Test the 16-Bit State Law

The archived narrative proposes this transform over 16-bit values:

```text
f(x) = rotl(x, 1) XOR rotl(x, 3) XOR rotr(x, 2) XOR 0x1D1D
```

The claim that this is a permutation cannot be inferred from the fact that it
uses rotations and XOR. The probe evaluates every one of the 65,536 possible
inputs and counts unique outputs:

```sh
busybox ash tests/probe-ideas.sh
```

The current result is:

```text
FACT    16-bit transform is bijective over all 65,536 inputs
FACT    every oscillator state returns after eight steps
```

These results validate the stated behavior of this exact transform. They do
not establish that another constant or another set of rotations has the same
properties.

## 5. Connect the Period to 1/73

The probe independently performs integer long division for `1/73`, rather than
assuming the decimal expansion from the narrative:

```text
1/73 = 0.01369863 repeating
```

The verified result is:

```text
FACT    1/73 has repeating block 01369863
```

This establishes two separate facts:

1. The selected 16-bit transform returns after eight steps for every state.
2. The decimal repetend of `1/73` has eight digits.

The test records the relationship between those facts. It does not claim that
the oscillator mathematically discovers the prime without defining the mapping
between the two systems.

## 6. Test the Fano Closure

The conversation gives a seven-bit closure rule. The probe applies that rule to
all 128 possible seven-bit inputs, applies two steps, checks stability with a
third step, and counts the distinct outputs:

```text
OBSERVED Fano two-step closure has 16 distinct outputs
```

This validates the observed 16-output quotient for the supplied line table.
The line table and bit ordering are part of the definition; changing either
changes the result.

## 7. Keep Shell Operations Distinct

The original experiments combine `tr`, `rev`, `cat -An`, and `diff`. They do
different jobs:

- `tr` substitutes characters
- `rev` reverses a line
- `cat -An` displays line numbers and control characters
- `diff` compares text streams

The probe checks the distinction directly:

```text
FACT    tr performs character substitution
FACT    rev performs string reversal
```

This matters because character substitution is not string reversal, and a
display pipeline must not be mistaken for a byte-level measurement.

## 8. What the BusyBox Tests Do Not Establish

The following runtime behaviors require separate environments and are
deliberately not reported as verified by this project:

```text
MANUAL  Browser audio execution, rendering, WebRTC, PiP, and pointer interaction
MANUAL  ESP32 GPIO/ADC, breadboard voltage levels, MIDI, Serial, and BLE
MANUAL  UDP transport, antenna matching, RF, and acoustic time-of-flight
MANUAL  LLM context integration and 144-agent visualization semantics
```

In particular, Hamming distance can detect a difference from an expected value,
but it is not authentication. UDP does not make a browser-accessible custom
options channel, and a browser audio or animation clock is not automatically a
hardware clock.

The dependency-free browser projection under `web/` wires the tested state law
into an `OfflineAudioContext`, an `OffscreenCanvas` fallback, metadata `VTTCue`
records, `DOMMatrix`, and a Shadow DOM custom element. `tests/check-web.sh`
verifies that those API surfaces are present in the source; it does not replace
browser execution or timing tests.

The HTTP/1.1 status arrays in `tests/http11-status-literals.txt` are likewise
syntax-checked protocol vocabulary for content-negotiation experiments only.
They are not authentication, trust, or agent identity proofs.

## 9. Reproduce the Whole Walkthrough

Use the BusyBox shell explicitly:

```sh
BUSYBOX=busybox busybox ash tests/run.sh
```

For the exhaustive 16-bit state validation and all narrative probes, run:

```sh
RUN_IDEA_PROBES=1 BUSYBOX=busybox busybox ash tests/run.sh
```

The default suite runs the fast control-byte analyzer tests. The optional probe
checks every 16-bit state and takes longer in a shell-only environment. It
reports `FACT` for claims that pass, `OBSERVED` for measured structure, `FAIL`
for a claim that does not match the implementation, and `MANUAL` for
integrations outside this shell harness.

The fast suite also runs the static browser API check and the HTTP/1.1 literal
array check. Those checks validate source vocabulary and structure, not browser
behavior or protocol negotiation.

That reporting format is intentional: the walkthrough validates the narrative
while it is being written, and preserves the difference between a proof, an
observation, and a future experiment.
