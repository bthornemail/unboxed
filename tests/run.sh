#!/bin/sh

set -eu

BUSYBOX=${BUSYBOX:-busybox}
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
TMP=$("$BUSYBOX" mktemp -d "${TMPDIR:-/tmp}/tetra-tests.XXXXXX")
trap '"$BUSYBOX" rm -rf "$TMP"' EXIT HUP INT TERM

# Include NUL and high-bit bytes so the test exercises raw-byte handling.
printf '\001\002\000\377' > "$TMP/word"
printf '\001\003\001\377' > "$TMP/god"
printf '\004\002\000\176' > "$TMP/of"
printf '\004\003\001\176' > "$TMP/OF"

OUTPUT=$($BUSYBOX sh "$ROOT/scripts/tetra-mask.sh" -v \
    "$TMP/word" "$TMP/god" "$TMP/of" "$TMP/OF")

assert_contains() {
    printf '%s\n' "$OUTPUT" | "$BUSYBOX" grep -F "$1" >/dev/null || {
        printf 'FAIL: missing output: %s\n' "$1" >&2
        exit 1
    }
}

assert_contains '  differing:  2 bits across 2 bytes'
assert_contains '  mask:       00010100'
assert_contains '  mask:       05000081'
assert_contains '  mask:       05010181'

printf '%s\n' 'PASS: tetra-mask control-byte fixtures'

# If the supplied BusyBox inventory artifacts are present, verify their length
# mismatch without truncation. They are optional experiment inputs.
if [ -r "$ROOT/full" ] && [ -r "$ROOT/list" ] && [ -r "$ROOT/full_list" ]; then
    UNEQUAL=$($BUSYBOX sh "$ROOT/scripts/tetra-mask.sh" \
        "$ROOT/full" "$ROOT/list" "$ROOT/full_list" "$ROOT/README.md")
    printf '%s\n' "$UNEQUAL" | "$BUSYBOX" grep -F 'not comparable' >/dev/null || {
        printf 'FAIL: unequal raw-byte vertices were not reported\n' >&2
        exit 1
    }
    printf '%s\n' 'PASS: unequal raw-byte vertices are not compared'
else
    printf '%s\n' 'SKIP: supplied full/list/full_list artifacts are absent'
fi

"$BUSYBOX" sh "$ROOT/tests/check-web.sh"
"$BUSYBOX" sh "$ROOT/tests/check-http11-status.sh"

if [ "${RUN_IDEA_PROBES:-0}" -eq 1 ]; then
    "$BUSYBOX" sh "$ROOT/tests/probe-ideas.sh"
else
    printf '%s\n' 'SKIP: exhaustive idea probes (set RUN_IDEA_PROBES=1 to run them)'
fi
