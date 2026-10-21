#!/bin/sh

# Build the three-layer BusyBox scalable lookup-table template:
#   outer view: full
#   center view: reversed side-by-side comparison
#   outer view: list
# The result defines a scalable table shape for inspection, not analyzer input
# or proof of the semantics assigned to any entry.

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
