from pathlib import Path
import json,re,hashlib
F=Path(__file__).resolve().parent.parent;R=F.parents[2];A=F/'resource_area_experiment';D=A/'alias_diagnostic';B=F/'fresh_i3_build_bound'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
ce=json.loads((D/'CE_BDD_ATTEMPT1.json').read_text());assert ce['status']=='PASS_CE_COMBINATIONAL_MITER_EQUAL';sat=json.loads((D/'SESSION_FAULT_SAT_PROOF.json').read_text());assert sat['status']=='PASS_LOCAL_NEXT_STATE_MITER_UNSAT_WITH_SAT_UNSAT_SANITY';camera=json.loads((D/'CAMERA_GRAY_MSB_PROOF_V2.json').read_text());assert camera['status']=='PASS_GRAY_MSB_IDENTITY_AND_ACTUAL_SOURCE_BINDING'
mapfiles=[B/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.v',A/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.v'];interfaces=[]
for net in ['dsi_pll_rstn_o','dsi_pll_lock','ddr_pll_lock','lvds_pll_lock','w_ddr3_cal_pass','w_ddr3_cal_done']:
 rows=[]
 for p in mapfiles:
  s=p.read_text();lines=s.splitlines();matches=[]
  if net=='dsi_pll_rstn_o':
   matches=[dict(line=i+1,text=l) for i,l in enumerate(lines) if 'assign dsi_pll_rstn_o = sys_pll_lock' in l];assert len(matches)==1;kind='ALIAS_OF_PRIMARY_INPUT_sys_pll_lock'
  elif net in ['dsi_pll_lock','ddr_pll_lock','lvds_pll_lock']:
   matches=[dict(line=i+1,text=l) for i,l in enumerate(lines) if re.match(r'\s*input '+net+r'\b',l)];assert len(matches)==1;kind='PRIMARY_INPUT_PLL_LOCK'
  else:
   matches=[dict(line=i+1,text=l) for i,l in enumerate(lines) if '.'+net+'('+net+')' in l];assert len(matches)==1;kind='UNCHANGED_DDR_CONTROLLER_PROTECTED_OUTPUT_CALIBRATION'
  rows.append(dict(map=rec(p),matches=matches))
 interfaces.append(dict(net=net,kind=kind,evidence=rows))
ff=[x for x in ce['leaves'] if 'cell' in x['old']];assert len(ff)==429 and all(x['old']['cell']==x['new']['cell'] for x in ff);paramdiff=[x['net'] for x in ff if x['old']['params']!=x['new']['params']];assert paramdiff==['\\u_m5b1/session_fault']
missing=json.loads((A/'EXACT_SELECTOR_GATE.json').read_text());candidates=json.loads((D/'MISSING_PIN_CANDIDATES.json').read_text());rows=[]
for x in candidates['rows']:
 if x['old_pin'].startswith('u_m5b1/telemetry_descriptor'):
  assert len(x['same_D_candidates'])==1;y=x['same_D_candidates'][0];assert y['same_params'] and all(y['same_control'][k] for k in ['D','CLK','SR']);assert x['old']['ports']['CE']=='\\u_m5b1/fusion/n21773' and y['cell']['ports']['CE']=='\\u_m5b1/fusion/n19065';new=y['name']+'|CLK';proof='Actual common64CE BDD + same D/CLK/SR/7params; source-bit index full64 preserved'
 else:assert x['old_pin']=='u_m5b1/video/camera_fifo/rg[9]~FF|CLK';new='u_m5b1/video/camera_fifo/rp[9]~FF|CLK';proof='Independent unchangedFIFO GrayMSB induction + actualcurrentrp9 through mask8888 to rgs1[9]D'
 groups=[g['name'] for g in missing['groups'] if x['old_pin'] in g['pins']];assert len(groups)==1;rows.append(dict(old_pin=x['old_pin'],new_pin=new,groups=groups,proof=proof,old_literal='^'+re.escape(x['old_pin'])+'$',new_literal='^'+re.escape(new)+'$'))
sdc=A/'mirror/efinity/m5c_fusion_i3/Ti60_Demo_I3.sdc';before=sdc.read_bytes();after=before
for x in rows:
 old=x['old_literal'].encode();new=x['new_literal'].encode();assert after.count(old)==1 and after.count(new)==0;after=after.replace(old,new)
inv=after
for x in rows:inv=inv.replace(x['new_literal'].encode(),x['old_literal'].encode())
assert inv==before and len(rows)==65
proofs=[D/'CE_BDD_ATTEMPT1.json',D/'SESSION_FAULT_SAT_PROOF.json',D/'CAMERA_GRAY_MSB_PROOF_V2.json',D/'MISSING_PIN_CANDIDATES.json',A/'EXACT_SELECTOR_GATE.json',R/'rtl/m5c_fusion/m5b1_async_fifo.sv',R/'rtl/m5c_fusion/m5c_display_session.sv',R/'efinity/m5c_fusion_i3/example_top.v']
p=D/'EXACT65_ALIAS_PROPOSAL.json';p.write_text(json.dumps(dict(status='PROPOSED_EXACT65_SOURCE_CLK_NAMES_NOT_APPLIED',rows=rows,CE_leaf_mapping=dict(named_FF=429,same7params=428,one_parameter_changed='session_fault with actuallocalNEXTSTATE_UNSAT',interfaces=interfaces,scope='SameRTL with retiming0/seq_opt0; identical named state cutpoints, not proof of every428D cone or fullcompiler.'),proofs=[rec(p) for p in proofs],constraints=dict(before=rec(sdc),proposed_sha256=hashlib.sha256(after).hexdigest(),bytes_unchanged=len(after)==len(before),inverse_byte_exact=True,groups=56,counts_unchanged=True,physical_5ns_unchanged=True,no_hold_or_reset_changes=True),boundary='camera route is logicalGrayMSB induction/currentmapbinding, not old/new protectedDDR wholecone equivalence. Prior65selectorFAIL and BDDlimits/ABCunknown-T retained. No SDC modified; Work approval required before newboundmap.'),indent=2));print(rec(p))
