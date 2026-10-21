# RFC Transport Notes

These notes anchor the transport discussion to the supplied RFCs rather than
the generated chat narrative.

The UDP security and port guidance below follows [RFC
8085](https://www.rfc-editor.org/rfc/rfc8085), which is the source of the port
and off-path-injection excerpt used in the discussion.

## RFC 4113: UDP Management

[RFC 4113](https://www.rfc-editor.org/rfc/rfc4113) defines the UDP Management
Information Base. It exposes UDP counters and an `udpEndpointTable` for
listening and connected UDP endpoints, including local and remote addresses and
ports.

This is management and observation data, normally accessed through SNMP. It is
not a UDP application frame format, a discovery protocol, or a connection
handshake. A connected UDP endpoint still does not provide TCP-style delivery,
ordering, or authentication.

## RFC 9868: UDP Options

[RFC 9868](https://www.rfc-editor.org/rfc/rfc9868) updates UDP with a transport
option framework. The options occupy a surplus area after UDP user data and
before the end of the IP transport payload. The framework defines:

- an option checksum area
- option kind and length formats
- safe and unsafe option classes
- ordering and malformed-option behavior
- reserved and assignable option kinds

RFC 9868 explicitly describes UDP Options as a framework, not a complete
application protocol. UDP remains stateless and unidirectional; application or
library layers provide any required session state and response behavior.

The RFC reserves option kind 9 for authentication. A Hamming or popcount match
in this project cannot replace that mechanism or provide sender authenticity.
The browser prototype cannot inject UDP transport trailers directly; a native
UDP endpoint, operating-system service, or gateway would be required.

## RFC 8085: UDP Usage and Off-Path Injection

RFC 8085 recommends that UDP applications avoid source port zero, use a
source-port value that is difficult for an off-path attacker to guess, and
perform receiver-side address and port checks. A randomized source port or
another randomized payload field can reduce off-path injection opportunities.

That is not self-authentication. RFC 8085 states that UDP does not provide
communications security and recommends established end-to-end mechanisms such
as IPsec or DTLS when authentication, integrity, or confidentiality are needed.
The source port is an input to an application defense, not an identity proof.

The repository's 65,536-byte check is a different property: it validates the
buffer length implied by the 16-bit state space. A valid length or valid state
orbit can reject malformed input, but it cannot prove who sent the input.
The narrower `tests/check-xor-xnor.sh` check validates only the byte relation
`xor ^ xnor = 0xff`.

## RFC 2675: IPv6 Jumbograms

[RFC 2675](https://www.rfc-editor.org/rfc/rfc2675) defines IPv6 Jumbo Payload
support for packets larger than 65,535 octets. It uses an IPv6 Hop-by-Hop Jumbo
Payload option and special UDP length handling.

This is unrelated to ordinary small state frames. It does not provide service
discovery, WebRTC signaling, MQTT discovery, or a general packet translation
layer.

## Repository Boundary

The current repository can validate:

```text
raw frame shape -> literal fields -> local byte comparisons
```

A future native transport adapter could map that frame into a UDP payload or a
proper RFC 9868 option. That adapter would still need explicit endpoint state,
sequence/replay behavior, integrity/authentication, and a discovery/signaling
layer. HTTP or MQTT can be application-level discovery mechanisms; WebRTC still
requires signaling and browser `RTCPeerConnection` execution.

The RFCs therefore support the existence of a standards-based UDP option path,
but they do not make the current shell or browser prototype a UDP translator.
