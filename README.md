# unboxed

This is a small BusyBox/POSIX-shell test project for the raw-byte tetrahedron
idea. Four files are treated as vertices. The harness evaluates all six
unordered edges without padding or truncating unequal files:

See [`docs/walkthrough.md`](docs/walkthrough.md) for the public narrative and
the evidence-backed walkthrough.
See [`docs/chat-outline.md`](docs/chat-outline.md) for the chronological claim
and proof map of the archived conversation.

- byte length
- byte-wise XOR mask
- differing-byte count
- differing-bit popcount

The first-principles template checker is `tests/probe-literals.sh`. Give it a
claim file when one is intentionally defined; it uses only BusyBox regular
expressions against tagged literal bit sequences and does not recompute values
or call the analyzer.

`tests/http11-status-literals.txt` is a separate tagged literal vocabulary for
HTTP/1.1 content-negotiation experiments. `tests/check-http11-status.sh`
validates its arrays with BusyBox regular expressions only; the codes are not
authentication or trust signals.

The optional `full`, `list`, and `full_list` files demonstrate the reference
index structure: path-qualified BusyBox applets, short applet names, and an
annotated line-number/control-character view. They are not generated source
code. Regenerate the basic reference index in one BusyBox shell line when
needed:

```sh
busybox --list-full > full; busybox --list > list; busybox cat -An full list > full_list
```

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
