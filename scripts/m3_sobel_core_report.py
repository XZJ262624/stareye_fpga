"""Record final warning deltas and exact mapped simulation isolation."""
from pathlib import Path
import json,re,hashlib
from m3_sobel_core_validate import ROOT,R,W
def warnings(path):
    text=path.read_text(errors='replace').split('Efinity Synthesis Started')[-1]
    lines=[x for x in text.splitlines() if 'WARNING' in x and x.startswith('[EFX-')]
    assert lines,'No warning records parsed; refuse an empty comparison'
    detailed=[x for x in lines if not re.search(r'Found \d+ warnings',x)]
    def norm(s):
        s=s.replace('m2_ar0135_ddr_hdmi_i3','PROJECT').replace('m3_sobel_core_i3','PROJECT')
        return re.sub(r':\d+\)$',':LINE)',s)
    return lines,detailed,{norm(x) for x in detailed}
old,od,os=warnings(ROOT/'efinity/m2_ar0135_ddr_hdmi_i3/outflow/Ti60_Demo.warn.log')
new,nd,ns=warnings(W/'outflow/Ti60_Demo.warn.log')
diff={'baseline_last_build_warning_lines':len(old),'m3_warning_lines':len(new),'baseline_detailed':len(od),'m3_detailed':len(nd),'new_normalized_messages':sorted(ns-os),'removed_normalized_messages':sorted(os-ns),'scope':'Last synthesis segment only; post-synthesis summary counted separately; inherited warnings retained.'}
(R/'WARNING_COMPARISON.json').write_text(json.dumps(diff,indent=2));assert not diff['new_normalized_messages'],diff['new_normalized_messages']
mapped=json.loads((R/'sim/mapped_summary.json').read_text())
data=Path(mapped['final_mapped_netlist']['path']).read_bytes();end=re.search(rb'^endmodule\s*$',data,re.M);cut=re.search(rb'    protected_cell protected_inst \(.*?\);',data[:end.end()],re.S)
isolation={'original':mapped['final_mapped_netlist'],'simulation_copy':mapped['simulation_copy'],'removed_instance':'protected_cell protected_inst (DDR only)','removed_start_byte':cut.start(),'removed_end_byte':cut.end(),'removed_sha256':hashlib.sha256(cut[0]).hexdigest(),'retained_module_end_byte':end.end(),'retained_sobel_reference_count_original':data[:end.end()].count(b'u_sobel_stream/'),'retained_sobel_reference_count_copy':Path(mapped['simulation_copy']['path']).read_bytes().count(b'u_sobel_stream/'),'verification':'Validator recomputes exact first-module minus this single instance, replacing it with one comment; no other netlist edit permitted.'}
(R/'sim/MAPPED_ISOLATION.json').write_text(json.dumps(isolation,indent=2))
print('M3_REPORT_DATA_PASS warnings',len(nd),'new',len(ns-os))
