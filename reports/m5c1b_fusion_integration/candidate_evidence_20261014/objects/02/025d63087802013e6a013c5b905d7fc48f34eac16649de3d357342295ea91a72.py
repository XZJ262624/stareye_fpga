from pathlib import Path
import json,hashlib,re,datetime
F=Path(__file__).resolve().parent;O=F.parent;M=O.parent;R=M.parents[2];W=O/'runs/aba_generation_negative_001146'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def load(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def put(p,obj):
 assert not p.exists(),str(p);p.write_text(json.dumps(obj,indent=2))
def chk(xs):
 for x in xs:assert rec(R/x['path'])==x,x['path']
 return len(xs)
r=load(W/'RESULT.json');assert r['status']=='PASS_EXPECTED_ABA_WRONGFUL_ACQUIRE_FATAL' and r['source_unchanged']
assert [s['stage'] for s in r['steps']]==['vlib','compile','sim']
assert all(s['exit']==0 and not s['timed_out'] for s in r['steps']);chk([s['log'] for s in r['steps']])
t=(W/'sim.log').read_text();fs=re.findall(r'\*\* Fatal: ([^\r\n]+)',t);assert len(fs)==1 and fs[0].startswith('SYSTEM_UI_SIGNATURE_REJECT_ACQUIRE ')
assert not re.search(r'\*\* Error:',t)
assert not re.search(r'\*\* (Error|Fatal):',(W/'compile.log').read_text())
inputs=load(W/'INPUTS.json');snaps=load(W/'SNAPSHOTS.json');assert chk(inputs)==103 and chk([x['snapshot'] for x in snaps])==103
selected=load(R/'reports/m5c1b_fusion_integration/final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json');assert chk([x['adopted'] for x in selected['records']])==101
assert chk(load(R/'reports/m5c1b_fusion_integration/SOURCE_PROTECTION.json'))==4465
plan=load(O/'aba_positive_handback_2339/GENERATION_BYPASS_PLAN.json');original=R/plan['production']['path'];b=original.read_bytes();m=(F/'mutant_display_session.sv').read_bytes();old=plan['old'].encode();new=plan['new'].encode();assert b.count(old)==1 and b.index(old)==9341 and m==b.replace(old,new) and m.replace(new,old)==b
assert rec(original)==plan['production'];assert hashlib.sha256(m).hexdigest()==plan['predicted_mutant_sha256']
compilecmd=next(x['owner']['command'] for x in r['steps'] if x['stage']=='compile');assert str(original) not in compilecmd;assert sum(Path(x).name=='mutant_display_session.sv' for x in compilecmd)==1
cmd=next(x['owner']['command'] for x in r['steps'] if x['stage']=='sim')
for p in ['-gBG_REQUEST_CYCLES=96000000','-gSERVICE_CYCLES=384','-gCAMERA_BLANK_CYCLES=478667','+SEED=71','-novopt']:assert p in cmd
assert any(x.startswith('+GOLD_B=') for x in cmd)
assert load(W/'EXIT_CIM.json')==[]
keys=['ABA_REAL_OFF','ABA_FENCE stage=1','ABA_ARM_REAL_A1','ABA_B2_BEGIN','ABA_SOURCE_REQUEST seq=77','SYSTEM_UI_SIGNATURE_REJECT req=','ABA_A3_BEGIN','ABA_SOURCE_REQUEST seq=78','** Fatal: SYSTEM_UI_SIGNATURE_REJECT_ACQUIRE']
events=[];last=-1
for k in keys:
 rows=[(i,l) for i,l in enumerate(t.splitlines(),1) if l.startswith('# '+k)];assert len(rows)==1,(k,rows);i,l=rows[0];assert i>last;last=i;events.append(dict(line=i,text=l))
mt=re.search(r'req=([0-9a-f]{40}) result=([0-9a-f]{40}) seq=(\d+)',fs[0]);assert mt;req,res,seq=int(mt[1],16),int(mt[2],16),int(mt[3]);assert seq==78 and req>>96==3 and res>>96==1 and (req&((1<<96)-1))==(res&((1<<96)-1))
b2=events[5]['text'];assert 'req_generation=2 result_generation=1' in b2 and 'req_seq=77 config_rejects=1 aba_rejects=0' in b2
br=re.search(r'req=([0-9a-f]{40}) result=([0-9a-f]{40})',b2);assert (int(br[1],16)&((1<<96)-1))!=(int(br[2],16)&((1<<96)-1))
assert '# SYSTEM_FRAME frame=75 mode=2 healthy=1 added=7 published=1' in t
arm=re.search(r'ABA_ARM_REAL_A1 .* identity=([0-9a-f]+)',t);assert arm;desc=int(arm[1],16);assert (desc>>576)&((1<<160)-1)==res
assert 'src=64 ui=64 start=64 done=64 take=64' in events[1]['text']
assert len(re.findall(r'^# ABA_SOURCE_REQUEST seq=78 ',t,re.M))==1
put(W/'NEGATIVE_CAUSAL_ORACLE.json',dict(status='PASS_EXACT_CONFIG_GENERATION_COMPARATOR_SENSITIVITY',events=events,first_A3=78,request_generation=3,result_generation=1,low96_equal=True,B2_low96_different_rejected=True,A1_full_descriptor_signature_matches=True,compile_exit=0,raw_sim_exit=0,unique_fatal=fs[0],elapsed_seconds=r['steps'][-1]['seconds'],scope='Expected fault injection rejection only, not ordinary positive simulation. No complete mutant UART or gen3 recovery claim.',observability='Original immutable TB logs full preedge signatures and observes after #1 req_take/acquire/offer/state/active_descriptor/session/token. Fatal proves this real post-edge rejection invariant failed. Individual acquire/state numeric values are not printed; acquire<=1/state<=ACQUIRE causality is the bound unique comparator RTL branch, not a separate waveform measurement.',oracle_source=rec(O/'aba_window_v3_2107/tb_aba_two_fence_v3.sv'),mutant=rec(F/'mutant_display_session.sv')))
put(W/'PROTECTION_POST.json',dict(selected_checked=101,protected_checked=4465,input_checked=103,snapshot_checked=103,mismatches=[],inverse_exact=True,owned_native_exited=True))
put(W/'GATE_HANDBACK.json',dict(status='PASS_NAMED_ABA_SENSITIVITY_ONLY',kind='aba',input_snapshot_checks=206,mismatches=0,native_result=rec(W/'RESULT.json'),causal_oracle=rec(W/'NEGATIVE_CAUSAL_ORACLE.json'),scope='Single isolated comparator mutant; production unchanged. No physical/build/board qualification. Raw simulator exit0 is not itself PASS. STOP for Work review.'))
records={x['path']:x for x in inputs}
for p in W.rglob('*'):
 if p.is_file() and 'work' not in p.relative_to(W).parts and p.name!='GATE_MANIFEST.json':records[rec(p)['path']]=rec(p)
records[rec(Path(__file__))['path']]=rec(Path(__file__))
put(W/'GATE_MANIFEST.json',dict(records=list(records.values())))
# Recheck all sealed replay gates, without modifying them.
gates=[];total=0
for p in sorted((O/'runs').glob('*/GATE_MANIFEST.json')):
 xs=load(p)['records'];total+=chk(xs);g=load(p.parent/'GATE_HANDBACK.json');gates.append(dict(run=p.parent.name,status=g['status'],manifest=rec(p),records=len(xs),handback=rec(p.parent/'GATE_HANDBACK.json')))
assert len(gates)==17,len(gates)
assert sum(x['status']=='PASS_CURRENT_FUNCTIONAL_CASE_AND_COMPLETE_WIRE' for x in gates)==15
assert sum(x['status']=='PASS_COLD_TERMINAL_ONLY_UART_ABORT_SCOPED' for x in gates)==1
assert sum(x['status']=='PASS_NAMED_ABA_SENSITIVITY_ONLY' for x in gates)==1
history=[]
for p in sorted((O/'runs').glob('*/RESULT.json')):
 rr=load(p)
 if rr['status']=='FAIL':history.append(dict(result=rec(p),status='Historical FAIL retained unchanged; no PASS credit'))
put(F/'FINAL_MATRIX_HANDBACK.json',dict(status='CURRENT_REPLAY_FUNCTIONAL_MATRIX_SEALED_STOP_FOR_WORK',gates=gates,manifest_record_checks=total,mismatches=0,counts=dict(complete_wire_positive=15,cold_terminal_scoped=1,named_ABA_negative=1),historical_failed_runs=history,negative=rec(W/'GATE_MANIFEST.json'),protection=rec(W/'PROTECTION_POST.json'),native_exit=rec(W/'EXIT_CIM.json'),boundaries=['Cold gate excludes normal source/UART drain and warm recovery.','Negative stops at expected wrongful-acquire invariant failure; no mutant complete stream or recovery claim.','Older legacy/default/focused packages remain their independently sealed evidence, not rerun or relabelled by this index.','Production UART defaults96MHz/460800 unchanged. Full-system wire tests use declared960kHz conditional clock; not default realtime throughput.','Resource47697/192/1 and prior STA diagnostic do not constitute fresh candidate fullbuild qualification; historical route binding gap retained.','No new build, STA, Git mutation or hardware actions. All old failures remain.']))
put(F/'SEAL_MANIFEST.json',dict(records=[rec(p) for p in [F/'FINAL_MATRIX_HANDBACK.json',W/'GATE_MANIFEST.json',Path(__file__)]]))
print(json.dumps(dict(negative_manifest=rec(W/'GATE_MANIFEST.json'),negative_records=len(records),matrix=rec(F/'FINAL_MATRIX_HANDBACK.json'),seal=rec(F/'SEAL_MANIFEST.json'),matrix_checks=total,gate_count=len(gates)),indent=2))
