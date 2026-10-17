# Fixed technical review entry: pack5 paired diagnostic prototype

This entry describes the selected working-source snapshot prepared for a new candidate whose sole parent must be711b802c8229544ded7f71905dcce16a3d57ac90. Actual new commit identity is supplied later by Work; preparation is not a commit or review approval. Root management docs and M3 work are intentionally excluded. Read this entry for the candidate's technical state rather than historical pending statements in preserved reports.

## Product and source boundary

This is an independent diagnostic image under rtl/m5c_pair_diag and efinity/m5c_pair_diag_i3. Old production108 inputs remain byte-identical. It preserves original video/fusion gates and all identities; it substitutes pair-only diagnostics for the previous type5 observer. Profile is type1/type4 plus6–10; legacy2/3 are absent in this image. Both complete reference class/mask and full current class/support/local/accepted-domain are exported. Current5bit samples are packed25 per128bit DDR word, retaining upper3 zero bits. Storage589824B,1152 realcurrentB plus1metadataB; wirecurrent921600B unchanged. Total completepair1268380B. Plane prefixes bind fullcapture/session/token; schema2 explicitly encodes six storage-layout u32 fields. The strict entry is scripts/m5c_pair_decode_pack5.py; older decoders remain historical, not permissive schema fallbacks.

The canonical107 input receipt is adoption/RECEIPT.json. Only the new prototype's rootSDC was adopted:276981B/SHA21e7db0df99508914fe9fec7fc9c7bf2a84b834dd9c21b119ac1cf16a545397a. This includes all addedpairCDC plus195 exact canonicalaliases; it is not merely195 root replacements. XML metadata/final newline and11settings paths differ reversibly from isolated build inputs; technical parameters are unchanged.

## Actual validation

Remote fixedV2, actual optimizedModelSim2020.4 +acc: compile/100us startup/fullvideo/software exited0. Fullvideo7050.893wallseconds,96M request cadence/service384/blank478667/seed50708,4s simulation and14400s wall budget unchanged. 35healthyframes cover seven modes(4,5,5,5,5,6,5), published2. Full1,302,076B mixedstream109packets: type1=2,type4=102,6–10 oneeach. EntireCRC/schema/identity/current921600 bytes and independentclass/support/localgold plus full8-neighborBFS reference921600maskpixels independently rechecked locally and byWork.102 source/UI/start/DONE/TAKE and finaltarget130/dualquiet close. Actual-control accepted-domain comparison is limited as described below.

The repaired naturalEOF path is directly observed: finalsample eligibility1; both tails eligibility0 but stablefullidentity1; producerDone,1152currentB,1metaB, retainedrelease/retire, realrelease→IDLE→nextpublication. DefaultSEPARATE_ELIGIBILITY0 exists only for oldstandaloneTB compatibility; production and newguards explicitly1. Knownproducererror enters cancellation/drain while keeping acceptedW/B payloadsource locked; originalreason wins same-edge capturetimeout. Twelvecaptureguards,tenerrorphase cases,two oldbehavior negatives,realbackend success/killreason3-token1 recovery,sixcontrollercases and three same-service384 fullsample cases form bounded repair coverage. Historical short inputs/qualifications are versioned in transport rather than silently claimed current whole-design regressions.

Additional selected focused evidence covers losslesspack5 lane/word/page/prefix/tail boundaries, densepacketbackpressure, stricthostnegatives,defaultdivider208 pin324B,fullSID/request/owner/lease clone behavior,qualificationloss and selection/telemetry repair. Check each RESULT/INPUTS/OWNER and its snapshot. ExpectedFatal rawexit0 is intentional only for a namednegative; invalid/failed exploratory runs are preserved where causal.

## Actual physical and offline artifacts

Fresh map/interface/place/route plus8I3queries and9audithelpers completed.49144XLR including1867routing/200RAM/1DSP within51680/204/128. NormalI3setup+.151ns/hold+.026ns; limitinghold paircapture pack→FIFORAM WDATA.29bundlegroups1638exactdestinations,maxCQ+data2.643ns/skew2.157ns;68selector groups. CurrentD/CE/SR/RAM/DSP/clockpair/control classification is bound to actualreports. Three inheritedPLL asynchronousSR endpoints remain expresslyUNTIMED, not timedPASS; seeKNOWN_LIMITS.

Offline conversion actualexit0/3.537s. Actualinstalled options do_program=false/run_usbif=false/do_security=false, nohardware. Bit2988918B SHA5485d2f8a6e597be7b2ed751bb1157f9a4f62ff698c5b3c738120af39ff3e0ab. Bit/nativeDB/tooloutputs are excluded fromGit; metadata and hashes are evidence, not hardwareacceptance.

## Reading evidence

TRANSPORT_INDEX.json maps originalpath+scope+SHA to deterministicgzip objects. Different historical bytes at the samepath stay separate. scripts/m5c_pair_read_evidence.py defaults to read-only streaming verification; explicit singleSHA extraction requires a new output outside the evidencepackage. DIRECT_REVIEW_INDEX.json lists complete original smallreports/logs and exactoffset excerpts for readers unable to execute/decompress; no excerpt is called complete. Large actualreport/structure bytes remain losslessly compressed. External map/routeDB/proprietarytool references are hash boundaries, not self-contained wholemappedlogic or compiler reconstruction.

Review priorities: finalsample/EOF identity separation; queuedcancel versus acceptedW/Bdrain; fullSID and realpublication/lease ownership;25lane/readprefetch/page/UARTprefix; completeplaneclass/support/local and storedaccepted-domain alignment; exactCDC endpoints and normalcontrols;explicituntimed reset boundary; no originalproduction algorithm change; accurate historical/current evidence scope.

No formal independentreview or hardwareacceptance is claimed. Work will freeze exactcandidate scope and authorize Git separately; only then may independent A/B review start.
