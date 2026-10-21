#!/bin/sh

# Probe the executable claims in the archived conversation. A failed claim is
# evidence about the idea, not a failure of the probe harness, so this script
# reports CLAIM/FACT/FAIL and exits zero unless the harness itself breaks.

set -eu

BUSYBOX=${BUSYBOX:-busybox}
TMP=$("$BUSYBOX" mktemp -d "${TMPDIR:-/tmp}/idea-probe.XXXXXX")
trap '"$BUSYBOX" rm -rf "$TMP"' EXIT HUP INT TERM

claim() {
    printf '%-7s %s\n' "$1" "$2"
}

rotl16() {
    ROT_X=$1
    ROT_N=$2
    ROT_RESULT=$(((ROT_X << ROT_N) | (ROT_X >> (16 - ROT_N))))
    ROT_RESULT=$((ROT_RESULT & 65535))
}

oscillate() {
    OSC_X=$1
    rotl16 "$OSC_X" 1; OSC_R1=$ROT_RESULT
    rotl16 "$OSC_X" 3; OSC_R2=$ROT_RESULT
    # rotr(x, 2) is rotl(x, 14).
    rotl16 "$OSC_X" 14; OSC_R3=$ROT_RESULT
    OSC_RESULT=$(( (OSC_R1 ^ OSC_R2 ^ OSC_R3 ^ 0x1D1D) & 65535 ))
}

fano_step() {
    FANO=$1
    p1=$(( (FANO >> 0) & 1 )); p2=$(( (FANO >> 1) & 1 ));
    p3=$(( (FANO >> 2) & 1 )); p4=$(( (FANO >> 3) & 1 ));
    p5=$(( (FANO >> 4) & 1 )); p6=$(( (FANO >> 5) & 1 ));
    p7=$(( (FANO >> 6) & 1 ))

    n1=$(( p1 | (p2 & p3) | (p4 & p5) | (p6 & p7) ))
    n2=$(( p2 | (p1 & p3) | (p4 & p6) | (p5 & p7) ))
    n3=$(( p3 | (p1 & p2) | (p4 & p7) | (p5 & p6) ))
    n4=$(( p4 | (p1 & p5) | (p2 & p6) | (p3 & p7) ))
    n5=$(( p5 | (p1 & p4) | (p2 & p7) | (p3 & p6) ))
    n6=$(( p6 | (p1 & p7) | (p2 & p4) | (p3 & p5) ))
    n7=$(( p7 | (p1 & p6) | (p2 & p5) | (p3 & p4) ))

    FANO_RESULT=$(( n1 | (n2 << 1) | (n3 << 2) | (n4 << 3) |
        (n5 << 4) | (n6 << 5) | (n7 << 6) ))
}

printf '%s\n' '=== EXECUTABLE IDEA PROBES ==='

# Verify that the current analyzer really emits six unordered edges.
FIXTURE=$TMP/fixture
printf '\000\001\002\003' > "$FIXTURE"
EDGE_OUTPUT=$($BUSYBOX sh "$(dirname "$0")/../scripts/tetra-mask.sh" \
    "$FIXTURE" "$FIXTURE" "$FIXTURE" "$FIXTURE")
EDGE_COUNT=$(printf '%s\n' "$EDGE_OUTPUT" | "$BUSYBOX" grep -c '^EDGE ')
[ "$EDGE_COUNT" -eq 6 ] && claim FACT 'four vertices produce six unordered edges' ||
    claim FAIL 'four vertices did not produce six unordered edges'

# Exhaustively test the claimed 16-bit permutation. This writes 65,536
# decimal outputs and lets BusyBox sort/uniq perform the uniqueness check.
OSC_OUTPUT=$TMP/oscillator
x=0
while [ "$x" -lt 65536 ]; do
    oscillate "$x"
    printf '%s\n' "$OSC_RESULT"
    x=$((x + 1))
done > "$OSC_OUTPUT"

OSC_UNIQUE=$("$BUSYBOX" sort -n "$OSC_OUTPUT" | "$BUSYBOX" uniq | "$BUSYBOX" wc -l)
if [ "$OSC_UNIQUE" -eq 65536 ]; then
    claim FACT '16-bit transform is bijective over all 65,536 inputs'
else
    claim FAIL "16-bit transform has $OSC_UNIQUE unique outputs, not 65,536"
fi

# Test the claimed period bound directly rather than inferring it from a few
# seeds. If every state returns after eight steps, the claim is true.
PERIOD_OK=1
x=0
while [ "$x" -lt 65536 ]; do
    y=$x
    n=0
    while [ "$n" -lt 8 ]; do
        oscillate "$y"
        y=$OSC_RESULT
        n=$((n + 1))
    done
    if [ "$y" -ne "$x" ]; then
        PERIOD_OK=0
        break
    fi
    x=$((x + 1))
done
[ "$PERIOD_OK" -eq 1 ] && claim FACT 'every oscillator state returns after eight steps' ||
    claim FAIL "period-8 claim fails at seed $x"

# Verify the decimal repetend independently with integer long division.
remainder=1
digits=
i=0
while [ "$i" -lt 8 ]; do
    digit=$(( (remainder * 10) / 73 ))
    remainder=$(( (remainder * 10) % 73 ))
    digits=$digits$digit
    i=$((i + 1))
done
if [ "$digits" = 01369863 ] && [ "$remainder" -eq 1 ]; then
    claim FACT '1/73 has repeating block 01369863'
else
    claim FAIL "1/73 probe produced $digits with remainder $remainder"
fi

# Exercise the archived Fano closure rule for every seven-bit input. Report
# the observed image size instead of assuming that it is a 16-state space.
FANO_OUTPUT=$TMP/fano
f=0
while [ "$f" -lt 128 ]; do
    fano_step "$f"; f1=$FANO_RESULT
    fano_step "$f1"; f2=$FANO_RESULT
    fano_step "$f2"; f3=$FANO_RESULT
    printf '%s %s\n' "$f" "$f2" >> "$FANO_OUTPUT"
    [ "$f2" -eq "$f3" ] || claim FAIL "Fano state $f is not stable after two steps"
    f=$((f + 1))
done
FANO_UNIQUE=$("$BUSYBOX" cut -d ' ' -f 2 "$FANO_OUTPUT" | "$BUSYBOX" sort -n | "$BUSYBOX" uniq | "$BUSYBOX" wc -l)
claim OBSERVED "Fano two-step closure has $FANO_UNIQUE distinct outputs"

# Demonstrate the shell distinction used by the original pipeline: tr maps
# characters, while rev reverses a line. This guards against conflating them.
TR_RESULT=$(printf '%s\n' taczx | "$BUSYBOX" tr 'abcdefghijklmnopqrstuvwxyz' 'zyxwvutsrqponmlkjihgfedcba')
REV_RESULT=$(printf '%s\n' taczx | "$BUSYBOX" rev)
if [ "$TR_RESULT" = gzxac ]; then
    claim FACT 'tr performs character substitution'
else
    claim FAIL "unexpected tr result: $TR_RESULT"
fi
if [ "$REV_RESULT" = xzcat ]; then
    claim FACT 'rev performs string reversal'
else
    claim FAIL "unexpected rev result: $REV_RESULT"
fi

printf '%s\n' '=== NOT EXECUTED IN BUSYBOX HARNESS ==='
claim MANUAL 'Web Audio, browser rendering, WebRTC, PiP, and pointer interaction'
claim MANUAL 'ESP32 GPIO/ADC, breadboard voltage levels, MIDI, Serial, and BLE'
claim MANUAL 'UDP transport, antenna matching, RF, and acoustic time-of-flight'
claim MANUAL 'LLM context integration and 144-agent visualization semantics'
