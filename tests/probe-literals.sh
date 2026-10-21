#!/bin/sh

# First-principles witness checks. This probe intentionally performs no
# arithmetic and does not call the implementation under test. It checks only
# tagged literal bit sequences with BusyBox regular expressions.

set -eu

BUSYBOX=${BUSYBOX:-busybox}
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
DATA=$ROOT/tests/literal-claims.txt

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

match() {
    "$BUSYBOX" grep -E "$1" "$DATA" >/dev/null || fail "missing literal: $1"
}

# Every record must be one of the explicitly tagged bit-sequence forms.
if "$BUSYBOX" grep -Ev \
    '^(K4_EDGE_[A-Z-]+ [01]{32}|BYTE_REVERSE_[0-9]+ [01]{8}=>[01]{8}|ENDIAN_SWAP_[0-9]+ [01]{16}=>[01]{16}|FANO_(LINE|CONSTANT)_[A-Z0-9]+ [01]{7}|FANO_CLOSURE_[A-Z0-9]+ [01]{7}=>[01]{7}|OSC16_SEED_[0-9]+ [01]{16}=>[01]{16}|DEC73_REPETEND_BCD [01]{32})$' \
    "$DATA" >/dev/null; then
    fail 'untagged or malformed literal record'
fi

# Exact witnesses transcribed from the narrative and the raw-byte fixture.
match '^K4_EDGE_WORD-GOD 00000000000000010000000100000000$'
match '^K4_EDGE_WORD-OF 00000101000000000000000010000001$'
match '^K4_EDGE_WORD-OF-UPPER 00000101000000010000000110000001$'
match '^BYTE_REVERSE_03 00000011=>11000000$'
match '^ENDIAN_SWAP_1234 0001001000110100=>0011010000010010$'
match '^FANO_LINE_123 0000111$'
match '^FANO_LINE_145 0011001$'
match '^FANO_LINE_167 1100001$'
match '^FANO_LINE_246 0101010$'
match '^FANO_LINE_257 1010010$'
match '^FANO_LINE_347 1001100$'
match '^FANO_LINE_356 0110100$'
match '^FANO_CONSTANT_EMPTY 0000000$'
match '^FANO_CONSTANT_POINT1 0000001$'
match '^FANO_CONSTANT_POINT2 0000010$'
match '^FANO_CONSTANT_POINT3 0000100$'
match '^FANO_CONSTANT_POINT4 0001000$'
match '^FANO_CONSTANT_POINT5 0010000$'
match '^FANO_CONSTANT_POINT6 0100000$'
match '^FANO_CONSTANT_POINT7 1000000$'
match '^FANO_CONSTANT_LINE356 0110100$'
match '^FANO_CONSTANT_LINE167 1100001$'
match '^FANO_CONSTANT_LINE257 1010010$'
match '^FANO_CONSTANT_LINE123 0000111$'
match '^FANO_CONSTANT_LINE347 1001100$'
match '^FANO_CONSTANT_LINE145 0011001$'
match '^FANO_CONSTANT_LINE246 0101010$'
match '^FANO_CONSTANT_FULL 1111111$'
match '^FANO_CLOSURE_BYTE22 0010110=>1111111$'
match '^OSC16_SEED_0001 0000000000000001=>0101110100010111$'

# Eight decimal digits are represented as eight four-bit BCD literals. This
# checks the bit encoding only; interpreting it as 1/73 remains a separate
# number-theory claim.
match '^DEC73_REPETEND_BCD 00000001001101101001100001100011$'

printf '%s\n' 'PASS: tagged literal bit-sequence witnesses'
