"""Fail-closed acceptance of current M3 build and isolated final I3 STA."""
from pathlib import Path
import hashlib,json,re,math,sys,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1];W=ROOT/'efinity/m3_sobel_core_i3';R=ROOT/'reports/m3_sobel_core_i3'
class InvalidEvidence(ValueError):pass
def need(c,m):
    if not c:raise InvalidEvidence(m)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def record(p):return {'path':p.relative_to(ROOT).as_posix(),'bytes':p.stat().st_size,'sha256':sha(p)}
def check_record(base,row):
    p=base/row['path'];need(p.is_file(),'missing '+str(p))
    need(p.stat().st_size==row['bytes'] and sha(p)==row['sha256'].lower(),'artifact hash/size mismatch '+str(p))
def parse_timing(text,kind):
    need('Version: 2025.1.110.5.9' in text,'wrong timing tool version')
    need('Timing Model: I3' in text and 'speedgrade : 3' in text and 'status : final' in text,'wrong timing model/status')
    need(re.search(r'User command: report_timing[^\n]* -'+kind+r'\b',text),'wrong timing check type')
    need(not re.search(r'\b(?:ERROR|FATAL)\b',text),'timing error')
    raw=re.findall(r'^Slack\s*:\s*(\S+)',text,re.M);need(bool(raw),'missing slack paths')
    try:values=[float(x) for x in raw]
    except ValueError:raise InvalidEvidence('invalid numeric slack')
    need(all(math.isfinite(x) and x>=0 for x in values),'negative/nonfinite slack')
    starts=re.findall(r'^Path Begin\s*:\s*(\S+)',text,re.M);ends=re.findall(r'^Path End\s*:\s*(\S+)',text,re.M)
    need(len(starts)==len(values)==len(ends),'incomplete timing path')
    return {'minimum_ns':min(values),'paths':len(values),'ends':set(ends),'starts':set(starts)}
def parse_coverage(text):
    need('Version: 2025.1.110.5.9' in text,'coverage version')
    expected={'no_clock':0,'unconstrained_internal_endpoints':0,'multiple_clock':0,'no_input_delay':5,'no_output_delay':136}
    for k,v in expected.items():
        values=re.findall(r'checking '+k+r' \((\d+)\)',text)
        need(len(values)==2 and all(int(x)==v for x in values),'coverage '+k)
    return expected
def parse_stages(text):
    need(not re.search(r'\b(?:ERROR|FATAL)\b',text),'compile error')
    result={k:re.findall(r'^\s*'+k+r'\s*:\s*(PASS|FAIL)',text,re.M) for k in ('map','interface','pnr','pgm')}
    need(all(v==['PASS'] for v in result.values()),'missing/duplicate/failing build stage')
    return result
def xml_semantic(path):
    root=ET.parse(path).getroot()
    for k in ('last_change','last_change_date'):root.attrib.pop(k,None)
    return ET.tostring(root)
def immutable_m2():
    old=json.loads((R/'m2_immutable_before.json').read_text(encoding='utf-8-sig'));base=Path(old['root'])
    rows={x['path']:x for x in old['files']};current={p.relative_to(base).as_posix() for p in base.rglob('*') if p.is_file()}
    missing=set(rows)-current;need(not current-set(rows) and missing<={'.lock'},'M2 file set changed');locked=[]
    for name,row in rows.items():
        if name in missing:continue
        p=base/name;st=p.stat();need(st.st_size==row['bytes'] and st.st_mtime_ns==row['mtime_ns'],'M2 metadata changed '+name)
        if 'sha256' in row:need(sha(p)==row['sha256'].lower(),'M2 content changed '+name)
        else:locked.append(name)
    return {'original_files':len(rows),'current_files':len(current),'original_bytes':sum(x['bytes'] for x in rows.values()),'metadata_only':locked,'transient_lock_missing':sorted(missing),'readable_content_and_metadata_unchanged':True}
def expected_reports():
    names={'m3_'+n+'.rpt' for n in ('setup','hold','check_timing','clocks','hdmi_setup','hdmi_hold','ddr_output_setup','ddr_output_hold','ddr_input_setup','ddr_input_hold','cmos_setup','cmos_hold','pixel_setup','pixel_hold')}
    for a,b in [('clk_sys','tac_clk'),('tac_clk','clk_sys'),('clk_sys','twd_clk'),('twd_clk','clk_sys'),('clk_sys','core_clk'),('core_clk','clk_sys')]:
        for kind in ('setup','hold'):names.add(f'm3_{a}_{b}_{kind}.rpt')
    for half in ('hi','lo'):
        for lane in range(16):
            for kind in ('setup','hold'):names.add(f'm3_ddr_lane_{half}_{lane}_{kind}.rpt')
    return names

def validate_simulation():
    from m3_sobel_core_sim import golden,read_observed,compare
    folder=R/'sim';binding=json.loads((folder/'binding.json').read_text())
    need(binding['source_before']==binding['source_after'],'simulation sources changed during run')
    need(len(binding['commands'])==3 and all(c['exit_code']==0 for c in binding['commands']),'simulation command failure')
    for row in binding['source_after']+binding['artifacts']:check_record(ROOT,row)
    counts={}
    for name,w,h in [('stream',9,7),('minimum_corners',3,3)]:
        stim=[[int(v) for v in line.split()] for line in (folder/(name+'_stim.txt')).read_text().splitlines()]
        expected=golden(stim,w,h)
        need(expected==json.loads((folder/(name+'_golden.json')).read_text()),'saved golden differs from spatial oracle')
        actual=read_observed(folder/(name+'_observed.txt'));compare(expected,actual)
        counts[name]={'cycles':len(actual),'valid_windows':sum(x['out_valid'] for x in expected)}
        log=(folder/(name+'.log')).read_text(errors='replace')
        need('HDL_STREAM_DONE '+str(len(actual)) in log and not re.search(r'\*\* (Fatal|Error):',log),'RTL run missing completion')
    video=(folder/'video.log').read_text(errors='replace')
    need('HDL_VIDEO_PASS frames=2 inputs=1843200 outputs=1843200 windows=1835208' in video,'video completion/counts')
    need('Loading work.R0_FIFO_8' in video and 'Loading work.lcd_driver' in video,'actual adapter modules missing')
    mapped=json.loads((folder/'mapped_summary.json').read_text())
    check_record(ROOT,mapped['final_mapped_netlist']);check_record(ROOT,mapped['simulation_copy'])
    need(mapped['pixels']==26882 and mapped['top_row_checks']==16642 and mapped['physical_ram_blocks']==4,'mapped RAM coverage')
    data=Path(mapped['final_mapped_netlist']['path']).read_bytes();end=re.search(rb'^endmodule\s*$',data,re.M)
    module,count=re.subn(rb'    protected_cell protected_inst \(.*?\);',b'    // Unrelated encrypted DDR instance isolated for RAM-path test.',data[:end.end()],flags=re.S)
    need(count==1 and module+b'\n'==Path(mapped['simulation_copy']['path']).read_bytes(),'mapped simulation isolation altered other logic')
    mappedlog=(folder/'mapped.log').read_text(errors='replace')
    need('HDL_MAPPED_RAM_PASS pixels=26882 top_row_checks=16642 cycles=28174' in mappedlog,'mapped completion')
    for log in (video,mappedlog):need(not re.search(r'\*\* (Fatal|Error):',log),'simulator fatal/error')
    negatives=json.loads((R/'negative_acceptance.json').read_text())
    need(len(negatives)>=23 and all(x['exit_code']==1 and x['rejected'] for x in negatives),'acceptance negative cases')
    controls=json.loads((R/'positive_acceptance.json').read_text())
    need(len(controls)==8 and all(x['exit_code']==0 for x in controls),'acceptance positive controls')
    nb=json.loads((R/'negative_binding.json').read_text())
    for row in nb['sources']+nb['artifacts']:check_record(ROOT,row)
    return {'spatial_checks':counts,'full_video_frames':2,'full_video_de_pixels':1843200,'full_video_valid_windows':1835208,'mapped_ram_pixels':26882,'mapped_two_row_read_checks':16642,'acceptance_negative_cases':len(negatives),'simulator':binding['simulator']}

def validate():
    build=json.loads((R/'build/result.json').read_text());need(build['exit_code']==0,'build exit failed')
    before={x['path']:x for x in json.loads((R/'build/input_before.json').read_text())}
    after={x['path']:x for x in json.loads((R/'build/input_after.json').read_text())}
    need(before.keys()==after.keys(),'build input sets differ')
    proj='efinity/m3_sobel_core_i3/Ti60_Demo.xml'
    need(all(before[k]==after[k] for k in before if k!=proj),'design input changed during build')
    need(sha(R/'build/project_before.xml')==before[proj]['sha256'],'before XML not bound')
    need(sha(R/'build/project_after.xml')==after[proj]['sha256'],'after XML not bound')
    need(xml_semantic(R/'build/project_before.xml')==xml_semantic(R/'build/project_after.xml'),'project semantic change during build')
    for row in after.values():check_record(ROOT,row)
    current={p.relative_to(ROOT).as_posix() for base in (W,ROOT/'rtl/m3_sobel_core') for p in base.rglob('*') if p.is_file() and p.name not in ('.lock',) and not any(x in ('outflow','work_syn','work_pnr','work_pt','ipm','work','cache') for x in p.relative_to(base).parts)}
    need(current==set(after),'unbound build input additions/removals')
    for row in build['outputs']:check_record(ROOT,row)
    stages=parse_stages((R/'build/compile.log').read_text(errors='replace'))
    binding=json.loads((R/'final_audit/binding.json').read_text())
    need(binding['exit_code']==0 and binding['original_unchanged'] and binding['original_before']==binding['original_after'],'STA exit/immutability failure')
    clone=Path(binding['clone'])
    for path,row in binding['original_after'].items():
        check_record(W,dict(path=path,**{k:row[k] for k in ('bytes','sha256')}))
        need((W/path).stat().st_mtime_ns==row['mtime_ns'],'original implementation timestamp changed')
        need(binding['clone_initial_hashes'][path]==row['sha256'],'clone source mismatch')
    for path in ('outflow/Ti60_Demo.bit','outflow/Ti60_Demo.lpf','work_pnr/Ti60_Demo.lbf'):
        need(sha(W/path)==sha(clone/path),'cloned database/bit differs')
    need(sha(W/'Ti60_Demo_I3.sdc')==sha(clone/'Ti60_Demo_I3.sdc')==binding['sdc_sha256'],'SDC binding')
    need(sha(ROOT/'scripts/m3_sobel_core_audit.tcl')==binding['tcl_sha256'],'Tcl binding')
    need(sha(R/'final_audit/audit.log')==binding['audit_log_sha256'],'audit log binding')
    log=(R/'final_audit/audit.log').read_text(errors='replace')
    need('ACTUAL_TIMING_MODEL I3' in log and 'M3_AUDIT_COMPLETE' in log and not re.search(r'\b(ERROR|FATAL)\b',log),'audit completion/model')
    expected=expected_reports();need({x['path'] for x in binding['reports']}==expected,'bound report set')
    need({p.name for p in (R/'final_audit').glob('m3_*.rpt')}==expected,'report additions/removals')
    timing={}
    for row in binding['reports']:
        check_record(R/'final_audit',row)
        name=row['path'];text=(R/'final_audit'/name).read_text()
        if name in ('m3_clocks.rpt','m3_check_timing.rpt'):continue
        parsed=parse_timing(text,'hold' if name.endswith('_hold.rpt') else 'setup')
        if name.startswith('m3_hdmi_'):need(parsed['ends']=={f'hdmi_txd{c}_o[{i}]' for c in range(3) for i in range(10)},'missing HDMI lane')
        if name.startswith('m3_ddr_lane_'):
            m=re.fullmatch(r'm3_ddr_lane_(hi|lo)_(\d+)_(setup|hold)\.rpt',name)
            need(parsed['starts']=={f'i_dq_{m[1]}[{m[2]}]'},'wrong DDR starting lane')
        if name.startswith('m3_ddr_output_'):
            ends={f'addr[{i}]' for i in range(16)}|{f'ba[{i}]' for i in range(3)}|{'ras','cas','we','cke','odt','cs'}
            ends|={f'o_dq_{kind}[{i}]' for kind in ('hi','lo','oe') for i in range(16)}
            ends|={f'o_dm_{kind}[{i}]' for kind in ('hi','lo') for i in range(2)}
            ends|={f'o_dqs{kind}_oe[{i}]' for kind in ('','_n') for i in range(2)}
            need(parsed['ends']==ends,'missing DDR output endpoint')
        timing[name]={k:v for k,v in parsed.items() if k not in ('ends','starts')}
    coverage=parse_coverage((R/'final_audit/m3_check_timing.rpt').read_text())
    seed=ROOT/'reports/m2_ar0135_ddr_hdmi_i3/final_build/source_snapshot'
    seed_rows=json.loads((R/'seed_manifest.json').read_text())
    need(len(seed_rows)==69 and sum(x['bytes'] for x in seed_rows)==2689858,'source snapshot count/size')
    for row in seed_rows:
        check_record(seed,row)
        if row['path'] not in ('example_top.v','Ti60_Demo.xml','Ti60_Demo.peri.xml'):
            check_record(W,row)
    need(sha(seed/'Ti60_Demo_I3.sdc')==sha(W/'Ti60_Demo_I3.sdc'),'validated SDC modified')
    for p in (seed/'ip').rglob('*'):
        if p.is_file():need(sha(p)==sha(W/p.relative_to(seed)),'baseline IP changed')
    def peri(path):
        root=ET.parse(path).getroot();root.attrib.pop('last_change_date',None)
        return ET.tostring(root)
    need(peri(seed/'Ti60_Demo.peri.xml')==peri(W/'Ti60_Demo.peri.xml'),'periphery changed beyond timestamp')
    resource=(W/'outflow/Ti60_Demo.place.rpt').read_text()
    resources={k:int(re.search(label+r': (\d+) /',resource)[1]) for k,label in [('xlr','XLRs'),('ram10','Memory Blocks'),('dsp','DSP Blocks')]}
    need(resources['ram10']==50 and resources['dsp']==0,'unexpected RAM/DSP realization')
    return {'status':'PASS_OFFLINE_SIMULATION_BUILD_AND_CONSTRAINED_STA','hardware_status':'NOT_TESTED_NO_PROGRAMMER_NO_DOWNLOAD_NO_FLASH','build_exit_code':0,'stages':stages,'inputs':len(after),'coverage':coverage,'timing':timing,'resources':resources,'bitstream':record(W/'outflow/Ti60_Demo.bit'),'m2_preservation':immutable_m2(),'simulation':validate_simulation()}

if __name__=='__main__':
    try:
        if len(sys.argv)>1 and sys.argv[1]=='--fragment':
            kind=sys.argv[2];p=Path(sys.argv[3]);text=p.read_text()
            if kind in ('setup','hold'):parse_timing(text,kind)
            elif kind=='coverage':parse_coverage(text)
            elif kind=='stages':parse_stages(text)
            elif kind=='record':check_record(ROOT,json.loads(text))
            elif kind=='build_exit':need(json.loads(text)['exit_code']==0,'build exit failed')
            elif kind=='report_set':need(set(json.loads(text))==expected_reports(),'report set incomplete')
            elif kind=='hdmi_setup':
                parsed=parse_timing(text,'setup')
                need(parsed['ends']=={f'hdmi_txd{c}_o[{i}]' for c in range(3) for i in range(10)},'missing HDMI lane')
            else:raise InvalidEvidence('unknown fragment')
            print('M3_FRAGMENT_PASS')
        else:
            result=validate();(R/'ACCEPTANCE.json').write_text(json.dumps(result,indent=2));print('M3_VALIDATION_PASS',json.dumps({k:result[k] for k in ('status','coverage','resources','bitstream','m2_preservation')}))
    except Exception as e:print('M3_VALIDATION_FAIL',e);sys.exit(1)
