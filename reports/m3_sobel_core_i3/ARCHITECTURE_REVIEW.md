# M3 architecture review

## Root source trace before implementation

2026-10-03. Base: `9a6d33db4dd3d5f6842cd43661a9a35409eadf1e`; branch: `feature/m3-sobel-core`. M3 is offline only.

Use `reports/m2_ar0135_ddr_hdmi_i3/final_build/source_snapshot` (69 compiled inputs) as seed. Current M2 GUI-regenerated auxiliary IP is not the verified compiled source. Keep the entire M2 directory unchanged, including generated outputs. `m2_immutable_before.json` captures file bytes and timestamps; explicitly marked unreadable files can only be compared by metadata.

Evidence in snapshot `example_top.v`: AXI read width 8 (lines 952ff); read clock `clk_pixel` (990); `~lcd_vs` is frame feedback (991); `lcd_request` advances the read FIFO (992); RGB replication is line 1022. `src/axi/axi4_ctrl.v:400-414` selects `R0_FIFO_8` and connects read clock/en/data. The stream is already in the pixel clock domain.

`src/lcd_driver.v`: HS/VS are active low; counters run continuously; registered request leads active display by one pixel (H_AHEAD=1). Registered pixel capture and DE at lines 124-131 align FIFO data for display. Request must not be equated with DE. Narrowing only lcd_driver DATA_WIDTH to 8, then feeding its aligned gray/DE/HS/VS into Sobel, is a candidate preserving the original read handshake and original frame feedback. Astra must confirm FWFT timing and simulate this adapter.

Active 1280x720, totals 1650x750; actual pixel PLL 74.4 MHz, not 74.25 MHz despite old labels. Preserve camera/DDR/HDMI pins, PLL, SDC budgets and external interfaces.

Distinguish full raster DE from convolution window-valid; invalid borders stay black while the full output raster and sync receive identical fixed wall-clock latency. Explicitly specify center (x-1,y-1) and output raster placement; never silently crop/shorten DE. Accepted-pixel progression must survive valid stalls. Use two line buffers, no full-frame buffer.

New reset asserts asynchronously and releases synchronously. Do not reset RAM arrays; suppress validity until populated. No new CDC is needed. Inherited M2 reset/CDC/old-Flash risks remain.

This is a preliminary root review. Astra must deliver its read-only architecture review before implementation; root independently reviews and releases the code phase.

## Astra review and released implementation contract

Root released implementation after reviewing the independent trace on 2026-10-03. The unchanged FWFT read FIFO presents a pixel before the pop edge. The registered request is already high at the edge where lcd_driver captures the first active pixel. Use lcd_driver DATA_WIDTH=8 and its lcd_rgb as gray; retain the original request and undelayed VS feedback. No baseline IP settings, PLL, pins, or SDC budgets change.

Core input: gray[7:0], in_valid, in_de, in_hs/in_vs (active low), in_sof (synchronous frame-abort/start level, no accepted pixel concurrently), threshold[7:0], mode[1:0]. The top drives in_valid=in_de and in_sof=~lcd_vs. Accepted pixels advance width-counted coordinates; gaps in valid never imply a new row. Each frame has WIDTH*HEIGHT pixels. Width/height must be at least 3. Reset asserts asynchronously, releases through two pixel-clock flops, and requires frame restart. RAM contents are not reset; two rows of validity suppression prevent stale data escaping.

Supported dimensions are 3..4096 inclusive (12-bit coordinates), checked by a simulation assertion. After reset the algorithm ignores remaining midframe input until SOF, and after WIDTH*HEIGHT accepted pixels it waits for the next SOF. Raw mode displays the delayed in_gray whenever in_de=1 even if in_valid=0; algorithm coordinates hold during such a gap. This convention keeps raster timing independent of algorithm stalls; the board adapter always has in_valid=in_de.

Five registered stages run in wall-clock time: (1) synchronous row reads/current pixel capture, (2) horizontal window capture, (3) signed Gx/Gy, (4) absolute sum and saturated magnitude, (5) threshold and output. An input sampled at edge n produces its output immediately after edge n+4. HS/VS/DE, raw gray, mode, threshold, slot and center coordinates follow the identical five-stage sampling convention, including blanking and valid gaps. Internal SOF clears row bookkeeping and pending writes, but does not erase already accepted pipeline outputs.

Window taps at input slot (x,y) cover rows y-2..y and columns x-2..x. Window-valid requires x>=2 and y>=2. The reported center is (x-1,y-1). Display slot (x,y) therefore contains the edge of center (x-1,y-1), explicitly one pixel right and down relative to original mode. No recentering is claimed. First two raster rows and first two columns are black in edge modes; DE remains full size. Valid centers span 1..WIDTH-2 and 1..HEIGHT-2; the final accepted input creates the final interior-center result.

Two WIDTH*8 inferred memories hold the previous one/two rows. At acceptance, both read address x synchronously. The following edge commits the saved current pixel to row1[x] and the saved row1 read to row2[x]. Concurrent next reads address a different accepted pixel, including wrap and stalls, so same-address read/write behavior is not required. SOF/reset cancels pending writes. Official Efinity inference with syn_ramstyle=block_ram produces the new Titanium RAM realization; unchanged existing IP is preserved. Check mapped primitives and simulate the mapped line-buffer circuit to verify inference.

Sobel uses signed 11-bit Gx/Gy (-1020..1020), unsigned 11-bit absolute values and 12-bit L1 sum. edge_gray=min(abs(Gx)+abs(Gy),255). edge_binary is 1 exactly when out_valid and edge_gray>=threshold; thus threshold 0 marks all valid windows including flat regions, threshold 255 marks saturated values. mode 0=raw gray, 1=saturated edge gray, 2/3=binary; top default is binary with threshold 64. Invalid algorithm outputs are zero; raw mode retains all active input pixels. New logic stays entirely in clk_pixel.
