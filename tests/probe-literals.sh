#!/bin/sh

# First-principles witness checks. This probe intentionally performs no
# arithmetic and does not call the implementation under test. It checks only
# tagged literal bit sequences with BusyBox regular expressions.

set -eu

BUSYBOX=${BUSYBOX:-busybox}
DATA=${1:-}

[ -n "$DATA" ] || {
    printf 'Usage: sh probe-literals.sh TAGGED_BIT_FILE\n' >&2
    exit 2
}

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

# Every record must be one of the explicitly tagged bit-sequence forms.
if "$BUSYBOX" grep -Ev \
    '^(K4_EDGE_[A-Z-]+ [01]{32}|BYTE_REVERSE_[0-9]+ [01]{8}=>[01]{8}|ENDIAN_SWAP_[0-9]+ [01]{16}=>[01]{16}|FANO_(LINE|CONSTANT)_[A-Z0-9]+ [01]{7}|FANO_CLOSURE_[A-Z0-9]+ [01]{7}=>[01]{7}|OSC16_SEED_[0-9]+ [01]{16}=>[01]{16}|DEC73_REPETEND_BCD [01]{32})$' \
    "$DATA" >/dev/null; then
    fail 'untagged or malformed literal record'
fi

printf 'PASS: tagged literal bit-sequence structure in %s\n' "$DATA"
