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

## Browser Projection

The dependency-free prototype is under `web/`. Serve it with BusyBox so the
module loads as an HTTP resource:

```sh
busybox httpd -f -p 8080 -h web
```

Open `http://127.0.0.1:8080/`. `tests/check-web.sh` checks the static API
surface; browser execution still requires a browser with the relevant APIs.
