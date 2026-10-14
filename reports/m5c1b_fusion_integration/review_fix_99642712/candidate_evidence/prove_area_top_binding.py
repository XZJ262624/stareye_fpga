from pathlib import Path
import json,re,hashlib,collections
E=Path(__file__).resolve().parent;F=E.parent;R=F.parents[2];old=F/'resource_area_experiment';new=F/'resource_area_bound'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix() if p.is_relative_to(R) else str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def digest(b):return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
paths=[d/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.v' for d in [old,new]];raw=[p.read_bytes() for p in paths];top=[];tails=[];ends=[]
for b in raw:
 matches=list(re.finditer(br'^endmodule[^\r\n]*(?:\r?\n|$)',b,re.M));assert len(matches)==1;end=matches[0].end();top.append(b[:end]);tails.append(b[end:]);ends.append(b[:end].count(b'\n'));assert len(re.findall(br'^module\s+example_top\b',b,re.M))==1
op=str(old/'mirror').encode();np=str(new/'mirror').encode();assert top[0].count(op)==top[1].count(np)>0
line_numbers=[]
for i,line in enumerate(top[0].splitlines(),1):
 if op in line:assert b'//' in line and line.index(b'//')<line.index(op);line_numbers.append(i)
normalized=top[0].replace(op,np);assert normalized==top[1] and top[1].replace(np,op)==top[0]
counts=collections.Counter(re.findall(br'^    (EFX_\w+)\s+',top[0],re.M));assert counts==collections.Counter(re.findall(br'^    (EFX_\w+)\s+',top[1],re.M))
proof=old/'alias_diagnostic/SESSION_FAULT_SAT_PROOF.json';j=json.loads(proof.read_text());external=[]
for x in j['bindings']:
 p=Path(x['path'])
 if p.is_absolute() and not p.is_relative_to(R):
  z=rec(p);assert z['bytes']==x['bytes'] and z['sha256']==x['sha256'];external.append(dict(historical=x,current=z))
versions=[]
for d in [old,new]:
 p=d/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.rpt';s=p.read_text();v=re.search(r'^Version:\s*(\S+)',s,re.M)[1];assert v=='2025.1.110.5.9';versions.append(dict(version=v,report=rec(p)))
p=E/'AREA65_CURRENT_TOP_BINDING.json';assert not p.exists();p.write_text(json.dumps(dict(status='PASS_COMPLETE_ACTUAL_TOP_EXACT_REVERSIBLE_SOURCE_COMMENT_REBASE',maps=[rec(p) for p in paths],top=[digest(b) for b in top],top_end_lines=ends,old_root=op.decode(),new_root=np.decode(),replacements=len(line_numbers),source_comment_line_numbers=line_numbers,normalized_old_equals_current=True,inverse_byte_exact=True,primitive_counts={k.decode():v for k,v in counts.items()},tails=[digest(b) for b in tails],tail_boundary='Trailing generated blackbox commentary and encrypted models differ. They are outside the sole actual example_top primitive instance/defparam netlist analyzed by the CE/session_fault/Gray proof. No whole-file or encrypted-model equivalence claim. Every actual top primitive/port/parameter/connectivity byte is identical after source-comment root rebase.',same_installed_proof_libraries=external,native_tool_versions=versions,proof_parent=rec(proof),generator=rec(Path(__file__)),scope='Binds prior area65 local primitive/cone proofs to current bound-map exact top. Not whole-chip sequential or encrypted DDR functional equivalence.'),indent=2));print('TOP_BINDING',ends,len(line_numbers),rec(p))
