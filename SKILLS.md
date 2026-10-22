# UNBOXED: SKILLS

The agent-readable index of the interactive entry. An agent that can read files —
over the sibling bridge (`repl/src/agent-bridge.ts`, MCP + loopback HTTP), over MQTT
presence (`repl/src/presence.ts`), or in the browser once a WebMCP surface is exposed —
reads this file and `AGENTS.md` and can then walk a newcomer through the entry in
plain language. Each skill is named in tag literals (`/^[A-Z0-9]{1,8}$/`), as the
`omi-files/` projects name theirs. Nothing here claims authentication; every law is
checked by the BusyBox harness, and this file only says what the pieces are and how
to run, serve, and read them. The provenance lives in these words, not only in the
author's head — that is the point: carry the chain, do not guess it.

## [SKILL_01: RUN_VERIFY_HARNESS]

`sh tests/run.sh`: the whole BusyBox harness — the raw-byte tetrahedron fixtures, the
XOR/XNOR complement, the 65,536-byte buffer, the reference-index grammar, unequal
vertices left not-comparable, the browser API surface, the HTTP/1.1 vocabulary. All
must pass. `RUN_IDEA_PROBES=1 busybox ash tests/run.sh` adds the slow exhaustive probes.

## [SKILL_02: SERVE_LOCAL]

`busybox httpd -f -p 8080 -h docs`, then open `http://127.0.0.1:8080/`. One binary, no
install, no network. The same `docs/` folder is the GitHub Pages source, so the entry
is also hosted at the repository's Pages URL. A `.nojekyll` marker keeps the module and
SVG served raw; the app uses only relative paths, so it works at the Pages sub-path.

## [SKILL_03: READ_E8]

The opening projection. Tell a newcomer: this is the exact E8 root system on its
Coxeter plane — 240 roots in 8 concentric shells of 30, each positive root paired with
its negative reflection — turning one Coxeter step (12°) at a time; 30 steps complete
the turn, 15 reach −1. It is the real figure from the proof (`docs/e8-step.svg`, from
`proofs/svg/e8/step.svg`), not a redrawing. The permutation law `nextState`
(`rotl16(1) ^ rotl16(3) ^ rotl16(14) ^ 0x1d1d`, the rule the probe checks) steps beside
it. It animates only while its spread is open.

## [SKILL_04: READ_COMMONS]

The Agent Commons. Tell a newcomer: the eight named narrators are the base — each at
once a sun (it pulls) and a planet (it orbits), each carrying its own local state. Their
centre of mass, the f-mean of the eight, is the global base; the 144 colour-name agents
are the field it holds, swayed by the eight's gravity. Each sun glows with the f-mean of
the hues it pulls — the colour of its combination. The constellation has a point of
view: a turn keeps the colour order, the other side reverses it. Same stars, read the
other way.

## [SKILL_05: READ_FANO]

The Fano converger. Tell a newcomer: pick any 7-bit byte; the rule "mark a XOR b for
every marked pair" settles it, in at most two steps, on one of 16 constants — the empty
set, the 7 points, the 7 lines, the full set. Checked over all 128 inputs in the proofs.

## [SKILL_06: READ_TETRA]

The tetrahedron. Tell a newcomer: four literals — WORD, GOD, OF, of — are the vertices,
and the six edges are their byte-wise differences with no padding. Only equal-length
pairs compare; the one literal edge, OF ↔ of, is a single bit per letter, `0x20` — the
case bit, lower to upper. The rest need the display layer to line up.

## [SKILL_07: READ_SWITCH]

The two switches. Tell a newcomer: one literal, read two ways. Direction reverses it;
encoding rot13s the letters. Each switch is its own inverse — flip twice and you are
back — and the frame underneath never changes, only the reading.

## [SKILL_08: INSPECT_CHANNEL]

How an agent connects to inspect and narrate: over the sibling bridge an agent is
reached by its tag (`//metatron.localhost:8743/...` or `/METATRON/...`); over MQTT it
subscribes to a presence topic (`omi/presence/<address>`) and hears who is broadcasting.
An agent reads this `SKILLS.md` and `AGENTS.md`, inspects the live entry, and explains
each spread in natural language — so a newcomer without the chain of provenance in their
head still sees what they are looking at. The channel is the pipe; these words are the
gift.
