# unboxed

This is a small BusyBox/POSIX-shell test project for the raw-byte tetrahedron
idea. Four files are treated as vertices. The harness evaluates all six
unordered edges without padding or truncating unequal files:

See [`docs/walkthrough.md`](docs/walkthrough.md) for the public narrative and
the evidence-backed walkthrough.
See [`docs/chat-outline.md`](docs/chat-outline.md) for the chronological claim
and proof map of the archived conversation.
See [`docs/rfc-transport-notes.md`](docs/rfc-transport-notes.md) for the
verified UDP and IPv6 standards boundary.

- byte length
- byte-wise XOR mask
- differing-byte count
- differing-bit popcount

The 16-bit state-space buffer invariant is checked separately by
`tests/check-16bit-buffer.sh`: a supplied buffer must contain exactly 65,536
bytes. This validates frame shape and bounds; it does not authenticate a
sender.

`tests/check-xor-xnor.sh` validates the narrower byte-level relation
`xor ^ xnor = 0xff` for equal-length inputs.

The first-principles template checker is `tests/probe-literals.sh`. Give it a
claim file when one is intentionally defined; it uses only BusyBox regular
expressions against tagged literal bit sequences and does not recompute values
or call the analyzer.

`tests/http11-status-literals.txt` is a separate tagged literal vocabulary for
HTTP/1.1 content-negotiation experiments. `tests/check-http11-status.sh`
validates its arrays with BusyBox regular expressions only; the codes are not
authentication or trust signals.

The optional `full`, `list`, and `full_list` files demonstrate a scalable
three-layer lookup-table template: `full` and `list` are the outer views,
while `full_list` contains their reversed comparison as a center view with
line-number and control-character markers. The construction defines the table
shape; the meaning assigned to individual entries remains a separate claim.
They are not generated source code. Regenerate the template with:

```sh
sh scripts/build-reference-index.sh
```

The center layer requires a `diff` implementation with `-y` (for example GNU
diff); BusyBox `diff` does not provide that option. Set `DIFF=/path/to/diff` if
needed. This optional display dependency does not affect the BusyBox analyzer.
When the three files are present, `tests/check-reference-index.sh` validates
their cross-frame visual grammar with BusyBox regular expressions.

The original `diff -y` pipeline is not used by the portable implementation
because BusyBox `diff` does not provide the `-y` option.

## Run

Requirements: BusyBox with `ash`, `od`, `tr`, `grep`, `wc`, `paste`, `printf`,
`mktemp`, and `rm`.

```sh
sh tests/run.sh
```

Run the longer exhaustive narrative probes separately:

```sh
RUN_IDEA_PROBES=1 BUSYBOX=busybox busybox ash tests/run.sh
```

Run the analyzer directly:

```sh
sh scripts/tetra-mask.sh full list full_list README.md
sh scripts/tetra-mask.sh -v full list full_list README.md
```

Set `BUSYBOX` to use a specific BusyBox binary:

```sh
BUSYBOX=/path/to/busybox sh scripts/tetra-mask.sh FILE1 FILE2 FILE3 FILE4
```

## Browser Projection — the interactive entry

`docs/` is the project's interactive entry — and the GitHub Pages source — a
dependency-free popup book you *operate*, served by one binary (or straight from
Pages). It is an `<agent-commons>` custom element (no imports, no CDN, no build)
with seven turnable spreads, each a working toy over a law the BusyBox harness
checks elsewhere — the UI shows shape, never authentication, and never becomes a
second state engine.

1. **Cover** — the invitation.
2. **The state commons** — the E8 root system on its Coxeter plane, piggybacking
   the actual proof SVG (`docs/e8-step.svg`, copied from `proofs/svg/e8/step.svg`
   in the sibling project): it is fetched and injected so its own SMIL rotation
   runs — 240 roots, each positive one paired with its negative reflection,
   turning 12° per Coxeter step (30 steps = a full turn, 15 = −1). The
   permutation law `nextState` (`rotl16(1)^rotl16(3)^rotl16(14)^0x1d1d`, the rule
   the probe checks) steps beside it, with an offline-audio render. A `DOMMatrix`
   canvas fallback draws the same figure when the page is opened over `file://`.
3. **The Agent Commons** — eight sovereign narrators are the **base**, each at once
   a **sun** (it pulls) and a **planet** (it orbits), each with its own local state.
   Their centre of mass — the **f-mean** of the eight — is the global base; the 144
   colour-name agents are the field it holds. Step the commons and the eight sway
   around their f-mean, and the gravity sways the 144. Each sun glows with the
   f-mean of the hues it holds (the colour of its combination); an observer control
   turns the vantage — a turn keeps the colour order, the other side reverses it.
4. **The Fano converger** — any 7-bit byte settles on one of 16 constants in ≤2 steps.
5. **The tetrahedron** — WORD · GOD · OF · of, the six edges, the one literal edge `0x20`.
6. **The two switches** — a literal read by direction (reverse) and encoding (rot13), each its own inverse.
7. **Open it** — how to serve and verify, the charter, the open question.

Serve it with BusyBox so the module and the SVG load as HTTP resources (a bare
`file://` open loses `fetch` and falls back to the canvas figure):

```sh
busybox httpd -f -p 8080 -h docs
```

Open `http://127.0.0.1:8080/`. `tests/check-web.sh` checks the static API surface
— that the browser primitives stay present and discoverable — and does not claim
a browser executed them.

GitHub Pages publishes the same `docs/` folder, so the entry is also hosted at the
repository's Pages URL. A `.nojekyll` marker keeps the module and SVG served raw
(no Jekyll processing); the app uses only relative paths, so it works at the Pages
sub-path unchanged.
