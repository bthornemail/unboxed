#!/bin/sh

# Build the three-layer BusyBox visual template:
#   outer view: full
#   center view: reversed side-by-side comparison
#   outer view: list
# The result is a display artifact for inspection, not analyzer input or a
# formally defined lookup table.

set -eu

BUSYBOX=${BUSYBOX:-busybox}
DIFF=${DIFF:-diff}
OUTPUT_DIR=${1:-.}

mkdir -p "$OUTPUT_DIR"
"$BUSYBOX" --list-full > "$OUTPUT_DIR/full"
"$BUSYBOX" --list > "$OUTPUT_DIR/list"

status=0
"$DIFF" -y "$OUTPUT_DIR/full" "$OUTPUT_DIR/list" > "$OUTPUT_DIR/.reference-center" || status=$?
if [ "$status" -gt 1 ]; then
    "$BUSYBOX" rm -f "$OUTPUT_DIR/.reference-center"
    printf 'reference index requires a diff implementation with -y\n' >&2
    exit "$status"
fi

"$DIFF" -y "$OUTPUT_DIR/full" "$OUTPUT_DIR/list" |
    "$BUSYBOX" rev |
    "$BUSYBOX" cat -An "$OUTPUT_DIR/full" - "$OUTPUT_DIR/list" > "$OUTPUT_DIR/full_list"

"$BUSYBOX" rm -f "$OUTPUT_DIR/.reference-center"
