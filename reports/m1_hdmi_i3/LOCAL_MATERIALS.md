# Local reference and tools inventory

Read-only inventory on 2026-10-01. Nothing in these directories was run, installed, moved, renamed or staged.

| Path relative to repository | Content and size | Purpose / Git recommendation |
| --- | --- | --- |
| reference/competition/Efinix_2026_FPGA_Track_Guide.pdf | 768,882 bytes; only current reference file | Official competition source; eligible for a separately reviewed source-document commit. Not part of this M1 source/build scope. |
| reference/board/, reference/camera/, reference/examples/ | Empty | Future curated source evidence, not wholesale copies of document/. |
| tools/gtkwave64/ | 1,155 files, 58,250,935 bytes; 58 exe/dll/zip files | Portable waveform viewer/converters; not required or invoked for this offline Efinity build. Keep outside a proposed M1 commit; no ignore-rule change hiding these user files was made. |
| tools/USB_Blaster驱动/ | 20 files, 24,442,114 bytes; includes ELITES-232DL.zip (11,351,297 bytes) and expanded driver | Parent folder name is misleading. The inspected INF declares ELITES-232DL, ElitesTek, VID_0403&PID_6014, libusbK, DriverVer 04/28/2014,3.0.7.0; matches the user's UB-ELITE-001/0403:6014 record. It is not evidence of an Altera USB-Blaster. Exclude this installer/driver archive from proposed M1 source commit. |

The download driver already works according to the user's M0/JTAG evidence. No reinstall, CH341 driver or ordinary UART driver is needed for this offline task. No executable binary was launched from tools/.

document/ remains ignored, in place and unchanged. Competition PDF and tools/ are still visible as untracked material; they have not been silently ignored or staged. No credentials were found in the M1 project configuration/scripts/text reports reviewed; this is not an exhaustive security audit of every vendor/tool file.
