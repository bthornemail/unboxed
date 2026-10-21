#!/bin/sh

# Static browser-surface check. This does not claim that a browser executed the
# APIs; it verifies that the dependency-free prototype keeps the requested
# browser primitives present and discoverable.

set -eu

BUSYBOX=${BUSYBOX:-busybox}
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
FILE=$ROOT/web/agent-commons.js

fail() {
    printf 'FAIL: missing browser primitive: %s\n' "$1" >&2
    exit 1
}

[ -f "$ROOT/web/index.html" ] || fail 'web/index.html'
[ -f "$FILE" ] || fail 'web/agent-commons.js'

for token in \
    'OfflineAudioContext' \
    'OffscreenCanvas' \
    'VTTCue' \
    'textTracks' \
    'DOMMatrix' \
    'attachShadow' \
    'customElements.define' \
    'matrix(';
do
    "$BUSYBOX" grep -F "$token" "$FILE" >/dev/null || fail "$token"
done

printf '%s\n' 'PASS: browser prototype API surface'
