# AR0135 horizontal orientation evidence

The one-bit change is supported by the camera vendor JeVois's own AR0135 Linux driver, not by a register definition borrowed from another sensor.

- Repository: https://github.com/jevois/jevois-sdk
- Fixed revision: `4feb7a290cf6f91963774bca12188a3740d9b00f`
- Driver: https://github.com/jevois/jevois-sdk/blob/4feb7a290cf6f91963774bca12188a3740d9b00f/linux-3.4/drivers/media/video/sunxi-vfe/device/ar0135.c
- Retrieved file SHA-256: `83b083753486c0eea89d898f3099161e2ab34a7cc37bbd62b6a0d4ff93fe48d1`.
- `sensor_g_hmirror`/`sensor_s_hmirror` at lines 363–397 read/modify register 0x3040 bit 14. `sensor_g_vflip`/`sensor_s_vflip` at lines 373–413 use bit 15. The setter preserves every other bit and writes no neighboring register.
- The same driver's `sensor_detect` at lines 555–567 accepts ID 0x0754 as AR0135 (and separately ID 0x2406 as AR0134). This is explicit AR0135 implementation evidence; it is not an onsemi register-reference document or a measurement of this board.
- JeVois documents its AR0135 sensor upgrade: https://jevois.org/doc/UserCli.html (AR0135 and ICM-20948 section).

The production top instantiates `I2C_AR0135_1280720_Config` with the 16-bit register/16-bit data sequencer, address byte 0x20, 96 MHz system clock, 50 kHz I2C, and SIMU_EN=0. Its LUT index 0 specifies a read from 0x3000. The attached 0x0554 data literal is not compared with the returned ID. Therefore neither that literal nor the inaccurate AR0144 filename header proves the actual hardware model. The established project identifies its camera as AR0135; current physical chip identity was not newly measured.

Changing LUT index 18 from 0x8000 to 0xC000 sets only the horizontal mirror bit and preserves vertical bit 15 and bits 13:0. It occurs after software-reset release (301A/10D8 has stream-enable bit 2 clear) and before the final stream-enable write (301A/10DC). This follows the same-model driver behavior without adding the neighboring-register requirements of unrelated sensor families. No new crop, gain, exposure, blanking, Bayer/resampling, or column-correction setting is invented.

The private user photograph is deliberately absent. Work's observation is that FPGA OSD reads normally while scene text is horizontally reversed. This supports correcting the scene at sensor readout rather than flipping the whole display. The intended physical result must still be verified using readable asymmetric text on the actual board after candidate review; the I2C test proves transactions, not sensor optical behavior.

## Scope of retained functional evidence

All 91 parent inputs were hash checked before preparation. New Efinity project files are exact copies except the single LUT bit; the shared 30 RTL inputs remain byte-identical parent references. Shape recognition, foreground DDR, LCD, HDMI, and OSD logic are unchanged. ROI coordinates continue to refer to displayed pixels. The centered ROI and circle/rectangle class meanings do not depend on image handedness, but finite thresholds, sample-grid discretization and scene placement are not claimed to yield identical confidence for every mirrored scene. The prior 72-frame video result is parent evidence only. No new full-video or physical-direction PASS is claimed from it.

The real serial test enumerates all 256 LUT addresses, checks LUT_SIZE=24, drives slave ACKs at the pins with production SIMU_EN=0 and clock-divider settings, and decodes every transmitted register/data word. It checks exactly one 3040/C000 write. The read response 0754 is a named electrical fixture only. It preserves and reports the two inherited 0000/0000 writes that comments label DELAY; this change does not repair unrelated historical sequencer behavior.
