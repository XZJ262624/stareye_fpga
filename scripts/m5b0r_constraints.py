"""Normalize same-source periods to the M2 DDR 2.604ns quantization lattice.

Efinity rounds independently generated sys96 to 10.417 when CORE reference is
used, vs 10.416 in M2. With DDR 5.208/2.604 this invents 0.001ns phase edges.
Retain ALL DDR I/O delays; change only sys96 to 4*2.604 and ref24 to 16*2.604.
This is a 64ppm conservative clock-period quantization, not a clock-speed change.
"""
from pathlib import Path
import re,json,hashlib
ROOT=Path(__file__).resolve().parents[1];W=ROOT/'efinity/m5b0r_ddr_address_diag_i3';R=ROOT/'reports/m5b0r_ddr_admission'
def main():
 p=W/'outflow/M5B0R_DdrDiag.pt.sdc';s=p.read_text();old=s
 s,n=re.subn(r'create_clock -period [0-9.]+ -name clk_sys ', 'create_clock -period 10.416 -name clk_sys ',s);assert n==1
 s+='\n# Common 2.604ns quantization lattice; actual oscillator remains 24MHz.\ncreate_clock -name clk_24m -period 41.664 [get_ports {clk_24m}]\n'
 # Monitor CDC stages remain timed. Synthesis can merge equivalent named
 # first stages; never emit a selector that silently matches no endpoints.
 # This signal only asserts until FPGA reconfiguration. It does not deassert
 # a reset during operation. Audit the reset synchronizers in the mapped IP;
 # exclude assertion into their ASYNCHRONOUS first stages only. Subsequent
 # synchronous release stages and all DDR data paths remain timed.
 netlist=(W/'outflow/M5B0R_DdrDiag.prevpr.v').read_text()
 async_names=re.findall(r"defparam \\(.+?) \.SR_SYNC = 1'b0;",netlist)
 reset_stages=[n for n in async_names if n.startswith('u_ddr/') and
  (re.search(r'r_srst_1P\[[012]\]~FF$',n) or
   n.endswith(('core_clk_rstn~FF','twd_clk_rstn~FF','tac_clk_rstn~FF','tdqss_clk_rstn~FF','logic_rstn~FF')))]
 assert reset_stages, 'no verified asynchronous reset synchronizers'
 target='^('+'|'.join(re.escape(n+'|SR') for n in reset_stages)+')$'
 s+='\n# Latched emergency reset assertion only; verified SR_SYNC=0 first stages.\n'
 # Efinity's selector does not accept the compound alternation used in the
 # first draft. One exact escaped selector per verified synchronizer stage.
 # All three pipeline registers share the same asynchronous assertion input.
 # Exclude only those verified SR pins. The D paths propagating synchronous
 # reset release through the pipeline remain fully analyzed.
 for name in reset_stages:
  s+='set_false_path -to [get_pins -regexp {^'+re.escape(name+'|SR')+'$}]\n'
 (W/'M5B0R_DdrDiag.sdc').write_text(s)
 (R/'CONSTRAINT_DERIVATION.json').write_text(json.dumps(dict(generated_sha256=hashlib.sha256(old.encode()).hexdigest(),final_sha256=hashlib.sha256((W/'M5B0R_DdrDiag.sdc').read_bytes()).hexdigest(),changed_clock_periods_ns={'clk_sys':10.416,'clk_24m':41.664},ddr_io_delay_lines_unchanged=True,monitor_sync_exception=False,reset_sync_async_SR_pins=reset_stages,emergency_reset_release='never during operation; startup release uses IP CYCLE=4 synchronizers, whose D paths remain timed',period_conservatism_ppm=64,clock_hardware_unchanged=True),indent=2))
 print('M5B0R_CONSTRAINTS_PASS')
if __name__=='__main__':main()
