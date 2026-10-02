# M1 clock, pin and source audit

Date: 2026-10-01. Current source configuration and fresh 2025.1.110.5.9 I3 reports take precedence over the archive's historical outputs.

## Proven source and board boundaries

Source XML: top Ti60_HDMI_1080P_Test; original C4; sw_version 2023.1.150.3.11; save timestamp 2023-09-23; historical location D:/SVN_Path/DevKitProjects/Ti60/Dev/07_Ti60_HDMI_1080P_Lvds_Test. Directory names HDK V2.1 (20251009) and Basic-2023.2 are distribution labels, not proof of the RTL project's PCB revision or compiler version. The original project contains no authoritative matching physical PCB revision. The supplied reference PDFs are core V1.4 and bottom board V1.1; the actual user's PCB revision remains unknown.

Reference files, read-only under the HDK's `04_原理图&PIN TCL/`:

- Ti60_Board_引脚定义-20230703-V1.0.xlsx.
- Ti60_F225_Core_V1.4.pdf.
- Ti60-F225_Button_Board_V1.1_20230915.pdf.

The root reviewer independently read the XLSX and both PDFs, rendered core page6 and bottom-board pages5/7 with Poppler, and visually checked the relevant connections. The following evidence was supplied during implementation: PDF page 5, title 04_HDMI_Display, date 2023-09-16, J2 HDMI-001, U1/U2 RCLAMP0524P ESD protection, C1..C8 0.1 uF AC coupling; page 7 P1 maps HDMI networks to GPIOT resources and requires BANK2A/2B 1.8 V. There is no external TMDS encoder/transmitter ASIC in this documented chain. This is evidence for the supplied drawing, not a declaration that the user's unseen board is the same revision.

## Display path

`lcd_driver` generates positive H/V sync, DE and coordinates; `lcd_display` generates RGB888; `rgb2dvi` instantiates three `tmds_channel` encoders. Each exports a 10-bit word, and four native HSIO LVDS TX serializers drive three data pairs and one clock pair through the documented coupling/protection network to HDMI J2. TMDS blue/control=data0, green=data1, red=data2. The image mode is DVI-style video/control over HDMI; no EDID transaction, audio, or data island transmission is implemented by this top. `ENABLE_OSERDES(0)` does not instantiate a fabric OSERDES; the module's SerialClk port is unused. `bitflip_i` is also unused by this implementation and therefore cannot be cited as polarity compensation.

All four interface blocks: 10-bit serialization, half-rate=true, slow clk_pixel, fast clk_pixel_5x, diff_type=lvds, VOD typical, pre-emphasis medium low, delay=0. Half-rate means 2 serial bits per fast-clock period: **742.5 MHz × 2 = 1.485 Gbit/s**, 10 bits per 148.5 MHz pixel. Interface resource validity passed. Electrical eye/margin and HDMI compliance were not measured.

## Physical mapping

Fresh `pinout.csv` supplies bank/ball/port mapping; fresh `pt.rpt` supplies native LVDS differential configuration (CSV's I/O Standard cells for HSIO are blank, not evidence of LVCMOS). XLSX root audit and reference drawings supply board-side networks.

| Signal | Native resource | FPGA P / N balls | Bank / configured supply | Standard / board evidence |
| --- | --- | --- | --- | --- |
| TMDS data0 / blue | GPIOT_PN_17 | A11 / B11 | 2B / 1.8 V | native LVDS; board hdmi_tx_data0 p/n |
| TMDS data1 / green | GPIOT_PN_00 | E6 / D5 | 2A / 1.8 V | native LVDS; board hdmi_tx_data1 p/n |
| TMDS data2 / red | GPIOT_PN_03 | A5 / A6 | 2A / 1.8 V | native LVDS; board hdmi_tx_data2 p/n |
| TMDS clock | GPIOT_PN_04 | F7 / F8 | 2A / 1.8 V | native LVDS; **both PDFs: F7 -> HDMI_CLK_P, F8 -> HDMI_CLK_N**; XLSX p/n labels conflict |
| Physical oscillator input | GPIOL_11_PLLIN2 | C5 | TL / 3.3 V | 3.3 V LVCMOS; 24 MHz |
| Unused legacy clock input | GPIOR_29_PLLIN2 | R13 | BR / 3.3 V | 3.3 V LVCMOS; unused pll_clkin warning |
| LED0..5 | GPIOR_25/22/28/21/24/27 | P15/P14/R14/N14/N13/P13 | BR / 3.3 V | 3.3 V LVCMOS; drive=4 |

Clock-pair source conflict: the XLSX labels are reversed, but root traced both schematics. Core PDF page6 identifies P1 B16 -> U1 F7 -> GPIOT_P_04 and P1 B17 -> U1 F8 -> GPIOT_N_04. Bottom-board PDF page7 assigns P1 B16 HDMI_CLK_P and B17 HDMI_CLK_N. Thus the two drawings support **F7 -> HDMI_CLK_P, F8 -> HDMI_CLK_N**, matching the native interface; the spreadsheet conflicts and may contain a labeling error. Do not claim the board is physically cross-wired, and do not swap pins based on the spreadsheet. The source clock word remains `10'b1111100000`; bitflip_i is unused. No pin or clock-pattern changes were made. Connector phase/electrical behavior and actual PCB/supply jumper state remain hardware-validation items.

## PLL calculation and actual frequency

The physical 24 MHz C5 pad is **not** the RTL port clk27m. clk27m is a 27 MHz core-facing PLL output used as the second PLL's reference. clk_pixel is another core-facing interface output at 148.5 MHz. Their names and interface ports must not be mistaken for physical package pins.

| Item | Current source and regenerated interface | Historical output/SDC |
| --- | --- | --- |
| First PLL | pll_27m at PLL_TL0, external C5/24 MHz, local feedback CLKOUT0=24 MHz, CLKOUT1=27 MHz | absent in old pt.rpt |
| Second PLL | sys_pll at PLL_TR0, core ref clk27m=27 MHz, local feedback clk_ref=27 MHz | sys_pll at PLL_BR0, external clk_25M=25 MHz |
| Pixel | 148.5 MHz, divider20 | 150 MHz, old SDC 6.6667 ns |
| Serializer fast | 742.5 MHz, divider4, phase setting2 = 90 degrees | 750 MHz, old SDC 1.3333 ns and 0.3333 ns phase |
| Feedback constraint | 37.037 ns / 27 MHz | 40 ns / 25 MHz |

Official PLL calculator: first M=N=1, O=2, feedback divider108 => VCO=24×216=5184 MHz, PLL=2592 MHz, /108=24, /96=27. Second M=N=O=1, feedback divider110 => VCO/PLL=27×110=2970 MHz, /110=27, /20=148.5, /4=742.5. Local feedback means the designated CLKOUT0 feeds the internal PLL feedback path; those unused core clock output ports can be absent from the core netlist without breaking the PLL loop.

Old VIP_System.sdc header is 2022.2.322.1.8/C4 (2023-02-03), while old pt.rpt is 2023.1.150 and describes the one-PLL 25/150/750 design. These do not match the saved September-2023 dual-PLL peri source. Using old SDC would constrain STA at 150 MHz while hardware still generates the current peri frequency; SDC does not program the PLL. The old target is ~1.01% faster, but wrong clocks, missing clk27m, old C4 interface requirements and stale PLL topology prevent treating it as a valid conservative signoff.

Active RTL macro: VGA_1920_1080_60FPS_148_5MHz. H=88 front+44 sync+148 back+1920 active=2200. V=4 front+5 sync+36 back+1080 active=1125. **148,500,000/(2200×1125)=60 Hz**; line frequency=67.5 kHz. At old 150 MHz the same counters would produce 60.6060606 Hz, not 60. Source comments mentioning 74.25/371.25 and 0.5 seconds are stale: DELAY_TOP=148500000 means four images rotate once per second at the configured clock (horizontal bars, vertical bars, product image, grayscale), a four-second cycle. This is a source-derived expectation, not observed video.

## SDC interpretation and coverage

The active SDC is an exact copy of the official I3 `pt.sdc` produced during configure. The compile flow subsequently regenerated its own `pt.sdc` with a later timestamp; non-comment constraint statements are identical (final_validation.json). Efinity documents PLL interface clocks using `create_clock` at the core/interface boundary; `create_generated_clock` is normally for clock division implemented in core logic. Therefore absence of create_generated_clock here is consistent with the official interface model, not proof that unrelated oscillators were added. This design contains no fabric-generated clocks. No false paths or asynchronous clock groups were added.

Physical relation: clk27m feeds sys_pll; clk_pixel/clk_pixel_5x are phase-related outputs of the same PLL. No user-data registers transfer between a 27 MHz domain and the pixel domain: all mapped 172 FF and DSP clock loads are clk_pixel. clk27m routes to the PLL reference; clk_pixel_5x routes to native serializers, not RTL flops. STA only shows pixel-to-pixel data relationships for this reason. Do not label 27 MHz and pixel as asynchronous or false-path them; a future data path between them needs renewed relationship/latency analysis.

Rounded official SDC periods: pixel 6.734 ns; fast 1.347 ns and waveform {0.337 1.010}. The clock report displays fast 742.390 MHz due to three-decimal period rounding; physical PLL calculator remains 742.500 MHz. Do not reprogram frequencies to match the formatted STA number.

Native LVDS parallel capture constraints are real generated device requirements, **not board-level HDMI receiver I/O delay guesses**: max0.435/min-0.140 ns for words/OE, max0.483/min-0.175 ns for reset, relative to each native slow-clock reference pin (coordinates63/195/31/55,322). Old C4 max values were0.378/0.420 ns. Independent I3 setup and hold reports enumerate all30 data endpoints with positive slack. Clock word and OEs/resets are constants and have no dynamic data transfer to time. This covers core-to-hard-serializer handoff, not the external cable/receiver analog link.

Official generated source-latency lines remain comments: first PLL input buffer2.193/1.271 ns; cascaded PLL includes clk27m network2.084/1.178 ns plus upstream source latency. No arbitrary board delay was invented. All dynamic timed data starts and ends in the same pixel clock domain (including native slow capture), so a common source latency cancels in this specific handoff; there is no external source-synchronous data input or cross-PLL data endpoint needing an assumed board/cascade latency budget. This reasoning does not extend to future camera input or cross-clock transfers.

No explicit set_clock_uncertainty was added. Efinity's device defaults are present in the actual I3 path reports: **setup0.126 ns, hold0.070 ns**. Local official `concept_constraints_uncertainty.html` documents automatic defaults and adding external-clock quality margins when known. Oscillator/cascade jitter beyond the tool's default allowance has not been measured or separately budgeted; physical robustness is not certified.

Local official sources: E:/Efinity/2025.1/doc/topics/tim-add-clock-create.html; tim-add-clock-creategen.html; tim-clock-latency-pll-cascading.html; concept_constraints_uncertainty.html; E:/Efinity/2025.1/pt/doc/topics/titanium-pll.html; titanium-hsio-as-lvds.html. Fresh reports and API calculations are archived here.



