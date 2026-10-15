# Stage1 observer field and edge contract

Status: standalone proposal implemented and focused-tested; NOT approved for production integration. The exact written table is finalized after the initial implementation/test iteration; it was not a prior Work-approved field freeze. Existing type1..4 and production files are untouched.

## Sampling and ownership
Single PIX-clock observer; SAMPLE_FRAMES defaults 60 (legal 1..65536), phase starts zero. Each true frame SOF advances the phase; phase zero requests a sample. Preparation is opportunistic on context_event while IDLE, then 21 clocks copy metadata into RAM. The full offered descriptor, token, epoch, slot and session MUST remain stable throughout PREP. context_valid and full64 SID are checked each PREP clock. At scheduled SOF, frame_admit plus full64 frame_session==prepared SID locks that prepared context for this frame. This is a pre-copy plus admission ownership fence, not reading live metadata at EOF. A late/unprepared/busy scheduled frame increments saturating64 dropped; production never waits. Producer stability during PREP is an integration prerequisite, not proven by SID equality alone. Distinct context events while busy may be lost to this observer, deliberately without affecting production.

Input final_de and frame_sof/eof must be true accepted PIX events, not CE-held level signals. The future adapter must qualify final events with actual pixel CE. context/reset/kill continue independently of CE. Source frame admission precedes its first output pixel. Periodic capture is tested with period2 and two different full64 SIDs; default60 counter selection has not been integrated in a full video system.

P0 independently combines accepted final_de, x<1280/y<720, legal_bounds, final_qualified, tag_good, frame_ok, !invalidate, delayed weak/support/global and !local_edge. P1 adds row_complete/equal/tag_good; P2 counts the separate actual promoted input. P3 counts actual fused RGB 00FFFF with actual mode6 and enable on accepted final pixels. P4 uses a one-clock delayed accepted-frame/mode/enable tag with actual registered OSD RGB/de, not P3 or pre-OSD RGB. The independent oracle counts each predicate from stimulus events; normal P1/P2 agreement is checked through separate expected fields.

All five counters are u32 saturating, never wrap. On CAPTURE kill or owner invalidation: no same-edge counts, ABORTED=1, reason OR bit31 for owner loss; previously accumulated counts remain. EOF counts its current pixel, enters TAIL; the next PIX clock counts the actual OSD last-pixel output, then seals. TAIL kill suppresses that last contribution and marks abort. Normal source release after EOF does not retrospectively invalidate completed pixel data. Reset immediately removes ready/ownership and counters; RAM contents are unreset and unqualified until a new complete record. No downstream may consume RAM when ready=0.

First difference requires current/reference qualifications, full SID equality to captured SID on BOTH sides, equal current/reference coordinates, legal1280x720 coordinates and class mismatch. Store only the first such event. Its two serialized full64 identities use captured SID because equality was actually checked on each side. No difference => first_valid0, first sample and identities0.

## Exact payload schema1
All fields little endian. Word means64bits; payload32 words=256B. Record/header RAM has40 words=320B. Full64 identities and160bit configuration are never truncated.

| Word / byte | Meaning |
|---|---|
|0 / 0|u32 schema=1; u32 flags bit0valid,1aborted,2first_valid,3saturated,4reserved0,5..7 admitted mode,8..31zero|
|1 / 8|u64 record sequence (successful admissions, reset0)|
|2 /16|u64 captured frame session; integration must bind to full display-frame identity, not a narrowed counter|
|3 /24|u64 admitted SOF pixel tick|
|4 /32|u64 EOF or abort pixel tick|
|5 /40|u64 current epoch|
|6 /48|u64 session|
|7 /56|u64 reader/context token|
|8 /64|u64 source epoch descriptor[63:0]|
|9 /72|u64 source job descriptor[191:128]|
|10 /80|u64 source ID descriptor[127:64]|
|11 /88|u64 source capture sequence descriptor[383:320]|
|12 /96|u64 source capture tick descriptor[575:512]|
|13 /104|u64 source slot generation descriptor[511:448]|
|14..15 /112..127|configuration[127:0]=descriptor[703:576]|
|16 /128|low32 configuration[159:128]=descriptor[735:704]; high32 nominal PIX Hz74400000 (SDC13.441ns is rounded; not an independent frequency measurement)|
|17 /136|low32 source slot bit0, others0; high32 nominal UI Hz96000000|
|18 /144|low32 P0; high32 P1|
|19 /152|low32 P2; high32 P3|
|20 /160|low32 P4; high32zero|
|21 /168|first diff bits0..11 currentx,12..23currenty,24..35refx,36..47refy,48..49currentclass,50..51refclass,52refmask,53currentqualified,54refqualified,55..57mode,58..63zero|
|22 /176|full64 qualified current SID, zero if no diff|
|23 /184|full64 qualified reference SID, zero if no diff|
|24 /192|u64 drop count sampled at SEAL word24, NOT an EOF-frozen drop count|
|25 /200|low32 abort reason; high32zero|
|26..31 /208..255|reserved allzero|

Header RAM words32..39: existing SM5B/v1 prefix, type5,64B header; payload length256 and reserved32zero; header bytes16..55 are source_descriptor[319:0] copied in PREP; bytes56..63zero. Host oracle serializes header64+payload256+little-endian CRC32=324B. Stage1 does not implement UART serialization or CDC: this is host formatting validation of actual RAM words, not a wire proof.

## Storage and read protocol
40x64 single write RAM with synchronous64bit read; memory port only observer. PREP writes metadata/header; SOF writes word3; EOF/abort word4; SEAL writes words0..2 and18..31 across32 clocks. READY only after final word. During READY no writes; ready/take handshake consumes record, next context may prepare after IDLE. Same-edge take before ready is ignored. Consumer sets read_word then samples after rising edge; read0..39 only. Production UART must eventually ACK only after its real packet_done, requiring a separately frozen bridge/CDC/storage design.

Declared sequential state outside RAM is approximately551 bits (includes64bit synchronous read data,64bit drop,128bit SID/sequence,160bit counts,32bit reason,64bit first sample, control). Combinational formatter intermediates are not additional state. 2560RAM bits may map to multiple physical RAM primitives due to64bit width. No synthesis has verified inference or actual FF/LUT/routing. 551 bits plus logic/routing is close to633XLR headroom; no fit claim. Reserve up to4 of12 available RAM provisionally, not measured. Do not integrate an extra full256B FF snapshot. If inference or resource fails, return to Work for storage/bridge revision without reducing identity widths or pixel guards.

## Proposed bindings, not implemented
A future m5c_fusion_display adapter exposes its admitted full session/offered tuple/token and real final delayed weak/support/ref/global/local/row-complete/tag predicates, plus actual promoted and fused RGB. Expose pre-row-gate predicates directly; do not derive P0/P1 from promoted. First compare observes real paired current/ref class with coordinates/SIDs. example_top supplies actual registered m5a_osd RGB/de and accepted PIX enable; existing fusion->OSD->rgb2dvi remains unchanged. No counter goes into the original pixel/control data path. Need prove full tuple stable over PREP and admission, one-cycle OSD alignment under CE gaps, EOF/kill arbitration, no CDC direct access, bridge RAM/ACK lifetime and periodic bandwidth. Any production ports/top/UART changes need a new Work freeze. New hardware/candidate/dual review gates remain outstanding.
