"""Candidate allocation audit. PASS is arithmetic/source consistency, NOT DDR qualification."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
from models import burst_plan

ROOT=Path(__file__).resolve().parents[2]
P=ROOT/'efinity/m5a_streaming_canny_i3'


def make_map():
    ranges=[]
    def add(name,start,end,fmt,rw,life,status,alignment=16):
        ranges.append(dict(name=name,start=start,end=end,start_hex=f'0x{start:08X}',end_hex=f'0x{end:08X}',bytes=end-start,alignment=alignment,pixel_format=fmt,access=rw,lifecycle=life,status=status))
    for i in range(4):
        base=i*(1<<22)
        add(f'video_{i}_payload',base,base+921600,'8-bit grayscale; 16 pixels/AXI beat','RW','existing four-slot video manager','existing',2048)
        add(f'video_{i}_slot_tail_FORBIDDEN',base+921600,base+(1<<22),'reserved full existing 4 MiB slot','NONE for M5B','never reassign: old writer pointer is 22 bits','forbidden',2048)
    addr=1<<24
    for kind,count,bpp,size in [('classification',2,2,230400),('work',2,1,115200),('result',2,1,115200)]:
        for i in range(count):
            start=addr; aligned=(size+4095)//4096*4096
            add(f'{kind}_{chr(65+i)}',start,start+size,f'{bpp} bit/pixel, low x in low bits','RW only assigned owner','capture/process/read leases, see ownership document','candidate_unqualified',16)
            if size<aligned:
                add(f'{kind}_{chr(65+i)}_alignment_hole',start+size,start+aligned,'padding','NONE','reserved','padding',16)
            addr+=aligned
    add('metadata_status',addr,addr+4096,'versioned 4 KiB page, 128-bit words','RW controller only','DDR mirror; registers authoritative','candidate_unqualified',4096)
    addr+=4096
    add('unallocated_configured_capacity_FORBIDDEN',addr,1<<29,'unqualified/unallocated','NONE','until separate range qualification','forbidden',4096)
    add('outside_configured_capacity_FORBIDDEN',1<<29,1<<32,'possible address alias / out of configured device','NONE','always forbidden','forbidden',4096)
    return dict(address_unit='byte',axi_address_bits=32,configured_physical_bytes=1<<29,verified_safe_new_bytes=0,candidate_start=1<<24,candidate_end=addr,ranges=ranges)


def check_map(m):
    ranges=sorted(m['ranges'],key=lambda x:x['start'])
    assert m['address_unit']=='byte' and m['axi_address_bits']==32
    end=0
    for r in ranges:
        assert 0<=r['start']<r['end']<=1<<32, r['name']+' overflow'
        assert r['start']==end, r['name']+' overlap or gap'
        assert r['start']%r['alignment']==0 and r['end']%r['alignment']==0, r['name']+' alignment'
        assert r['bytes']==r['end']-r['start'], r['name']+' size'
        if r['status']=='candidate_unqualified':
            assert r['end']<=m['configured_physical_bytes'], r['name']+' physical overflow'
            assert r['start']>=1<<24, r['name']+' existing slot conflict'
            plan=burst_plan(r['start'],r['bytes'])
            assert sum(n for _,n in plan)==r['bytes']
            assert all(a//4096==(a+n-1)//4096 for a,n in plan)
        end=r['end']
    assert end==1<<32
    return True


def source_checks():
    evidence=[]
    checks={
      'Ti60_Demo.xml':['src/axi/axi4_ctrl.v','DdrCtrl.sv'],
      'example_top.v':['wire\t\t\tw_ddr3_ui_clk = clk_sys','.C_RD_END_ADDR(1280 * 720)', '.C_ID_LEN(4)', 'assign w_ddr3_asize = 4','axi_bvalid     (1'],
      'src/axi/axi4_ctrl.v':['C_DATA_LEN    = 128','C_BURST_LEN   = 128','C_BUF_SIZE    = 22','C_ADDR_INC    = C_BURST_LEN * C_STRB_LEN','C_BASE_ADDR + {rc_wframe_index, rc_w_ptr}','C_BASE_ADDR + {rc_rframe_index, araddr}'],
      'ip/DdrCtrl/DdrCtrl.sv':['input [31:0] axi_aaddr','input [127:0] axi_wdata','input [15:0] axi_wstrb','`pragma protect begin_protected'],
      'Ti60_Demo.peri.xml':['ref_clock_freq="96.0000"','feedback_clock_name="clk_sys"','out_divider="31"'],
      'outflow/Ti60_Demo.place.rpt':['9425 / 60800','105 / 256','0 / 160']}
    for path,needles in checks.items():
        data=(P/path).read_bytes(); s=data.decode('utf-8-sig')
        lines=s.splitlines()
        for needle in needles:
            matches=[i+1 for i,line in enumerate(lines) if needle in line]
            assert matches,(path,needle)
            evidence.append(dict(path=str((P/path).relative_to(ROOT)).replace('\\','/'),needle=needle,lines=matches,sha256=hashlib.sha256(data).hexdigest()))
    cfg=json.loads((P/'ip/DdrCtrl/settings.json').read_text())['conf']
    assert (cfg['row'],cfg['col'],cfg['bank'],cfg['freq'])==('15','10','3','384')
    assert 2**(int(cfg['row'])+int(cfg['col'])+int(cfg['bank']))*2==1<<29
    # Report actual M2 live/snapshot differences, never assume historical working inputs identical.
    comp=[]
    for rel in ('src/axi/axi4_ctrl.v','src/axi/AXI4_AWARMux.v','ip/DdrCtrl/settings.json','ip/DdrCtrl/DdrCtrl.sv'):
        ref=(P/rel).read_bytes()
        for base in ('efinity/m2_ar0135_ddr_hdmi_i3','reports/m2_ar0135_ddr_hdmi_i3/final_build/source_snapshot'):
            f=ROOT/base/rel
            comp.append(dict(path=str(f.relative_to(ROOT)).replace('\\','/'),exists=f.exists(),same_as_m5a=f.exists() and f.read_bytes()==ref,sha256=hashlib.sha256(f.read_bytes()).hexdigest() if f.exists() else None))
    return evidence,comp


def execute(out):
    m=make_map(); check_map(m)
    neg=[]
    for name,mutation in [('overlap',lambda x:x['ranges'][8].update(start=(1<<24)-16)),('overflow',lambda x:x['ranges'][-1].update(end=(1<<32)+4096)),('misalignment',lambda x:x['ranges'][8].update(start=(1<<24)+1)),('wrong_size',lambda x:x['ranges'][8].update(bytes=1)),('wrong_unit',lambda x:x.update(address_unit='128-bit beat')),('physical_capacity',lambda x:x.update(configured_physical_bytes=1<<24))]:
        bad=copy.deepcopy(m); mutation(bad)
        try: check_map(bad)
        except AssertionError: neg.append(dict(case=name,rejected=True))
        else: raise AssertionError(name+' not rejected')
    evidence,comp=source_checks(); out.mkdir(parents=True,exist_ok=True)
    (out/'DDR_ADDRESS_MAP.json').write_text(json.dumps(m,indent=2),encoding='utf-8')
    (out/'ADDRESS_CHECK_RESULTS.json').write_text(json.dumps(dict(status='PASS_ARITHMETIC_ONLY',safe_new_hardware_range_confirmed=False,positive=1,negative=neg,source_evidence=evidence,m2_comparison=comp),indent=2),encoding='utf-8')
    lines=['# DDR候选地址图（半开字节区间）','','计算检查PASS不等于DDR高位解码/硬件读回PASS。新增安全地址实际确认量为0；所有M5B地址均为待验证候选。4MiB视频槽尾整体禁止复用。','', '|用途/缓冲|[start, end)|字节数|对齐B|格式|权限|状态|','|---|---|---:|---:|---|---|---|']
    for r in m['ranges']:
        lines.append(f"|{r['name']}|[{r['start_hex']}, {r['end_hex']})|{r['bytes']}|{r['alignment']}|{r['pixel_format']}|{r['access']}|{r['status']}|")
    lines+=['','每张分类图行步长320B、共230400B，每张1b图行步长160B、共115200B；均精确16B拍对齐。槽分配按4KiB上取整，尾孔禁止业务写入。burst planner采用最大128拍、帧末短burst且切断4KiB边界，不能直接重用旧控制器固定128拍的帧尾逻辑。生命周期见 BUFFER_OWNERSHIP_AND_CDC.md；各候选图只允许登记的唯一写者。','地址证据、尚未证明的高位别名/跨bank映射及端口限制见 DDR_SOURCE_AUDIT.md。JSON为审计数据，不是生产RTL参数。']
    (out/'DDR_ADDRESS_MAP.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print('ADDRESS PASS: 1 positive, 6 negative; hardware qualification UNKNOWN')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=Path(__file__).parent);execute(p.parse_args().output)
