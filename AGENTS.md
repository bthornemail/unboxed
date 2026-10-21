# Repository Guidance

- The implementation is a POSIX-shell/BusyBox test harness; do not introduce a language runtime or package manager for the core analyzer.
- The executable entrypoint is `scripts/tetra-mask.sh`; it accepts exactly four files and compares all six unordered raw-byte pairs.
- `tests/run.sh` is the verification command. It uses temporary control-byte fixtures and must remain runnable with BusyBox `ash`.
- `tests/probe-ideas.sh` is an intentionally slower exhaustive narrative probe; run it with `RUN_IDEA_PROBES=1` when validating the 16-bit, Fano, decimal-cycle, and shell-semantics claims.
- `tests/probe-literals.sh` is the first-principles template check: it must remain arithmetic-free and validate only tagged fixed-width bit literals with BusyBox regular expressions.
- `web/index.html` and `web/agent-commons.js` are a dependency-free browser projection; `tests/check-web.sh` is only a static API-surface check, not browser execution proof.
- `tests/http11-status-literals.txt` and `tests/check-http11-status.sh` are literal protocol vocabulary checks; HTTP status codes must not be presented as authentication or trust proofs.
- `tests/check-reference-index.sh` checks the `full`/`list`/`full_list` visual frame grammar with BusyBox regular expressions; it validates shape, not applet semantics or arithmetic.
- `docs/rfc-transport-notes.md` is the repository's verified boundary for RFC 4113, RFC 9868, and RFC 2675; do not infer browser UDP access, discovery, or authentication from those standards.
- The analyzer must not pad or truncate unequal files. Report those edges as not comparable.
- `_archive/` is untracked historical material, not an implementation source tree. Preserve it unless the task explicitly concerns the archive, and do not infer current architecture or requirements from its contents.
- `full`, `list`, and `full_list` are optional scalable lookup-table templates: `full` and `list` are the outer views, and `full_list` contains the reversed comparison between them. Regenerate them on demand with `scripts/build-reference-index.sh`; they are not required for the core tests.
- Check `git status --short` before and after work; unrelated archive and artifact changes may be present.
