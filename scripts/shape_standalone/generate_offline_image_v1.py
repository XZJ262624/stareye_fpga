"""Authorized offline conversion in a NEW copy, never the sealed route mirror."""
from common import *
import shutil,zlib
W=O/('bit_generation_'+time.strftime('%Y%m%d_%H%M%S'));W.mkdir(exist_ok=False)
A=json.loads((O/'ACTIVE_PHYSICAL.json').read_text());F=R/A['path'];old=R/A['project'];new=W/'mirror/efinity/shape_standalone_i3'
source=json.loads((O/'SOURCE_MANIFEST.json').read_text());verify(source)
sealed=[rec(q)for q in sorted((F/'mirror').rglob('*'))if q.is_file()]
db=[rec(q)for q in sorted((old/'work_pnr').rglob('*'))if q.is_file()]
save(W/'INPUTS_PRE.json',dict(canonical_sources=source,sealed_mirror=sealed,routed_db=db,physical_final=rec(F/'FINAL_PHYSICAL_RECEIPT.json'),clock_final=rec(F/'NATIVE_PRIMITIVE_CLOCK_COVERAGE_V3.json'),helper=rec(Path(__file__))))
save(O/'pre_candidate/ACTIVE_BIT_GENERATION.json',dict(path=W.relative_to(R).as_posix(),project=new.relative_to(R).as_posix(),manager_pid=os.getpid(),running=True))
try:
 shutil.copytree(F/'mirror',W/'mirror')
 for x in sealed:
  p=R/x['path'];q=W/'mirror'/p.relative_to(F/'mirror');y=rec(q);assert y['bytes']==x['bytes']and y['sha256']==x['sha256'],x['path']
 save(W/'COPY_VERIFIED.json',dict(passed=True,count=len(sealed),bytes=sum(x['bytes']for x in sealed)))
 cmd='call E:\\Efinity\\2025.1\\bin\\setup.bat && call E:\\Efinity\\2025.1\\bin\\efx_run.bat Ti60_Demo.xml --flow pgm'
 start=time.time()
 with (W/'native.log').open('wb')as log:
  p=subprocess.Popen(['cmd.exe','/d','/c',cmd],cwd=new,stdout=log,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
  owner=dict(pid=p.pid,manager_pid=os.getpid(),cwd=str(new),command=cmd,running=True,started=start);save(W/'OWNER.json',owner);print(json.dumps(owner),flush=True)
  code=p.wait(timeout=900)
 owner.update(running=False,exit=code,seconds=time.time()-start);save(W/'OWNER.json',owner)
 text=(W/'native.log').read_text(errors='replace');assert code==0 and not re.search(r'(?im)^ERROR|\[ERROR\]|Flow skipped: Bitgen was not executed',text),text[-10000:]
 verify(source);verify(sealed);verify(db)
 for x in db:
  q=new/'work_pnr'/(R/x['path']).relative_to(old/'work_pnr');y=rec(q);assert y['bytes']==x['bytes']and y['sha256']==x['sha256'],x['path']
 # Bitgen may update only new copy metadata; preserve and expose every changed file.
 changes=[]
 for x in sealed:
  q=W/'mirror'/(R/x['path']).relative_to(F/'mirror');y=rec(q)
  if y['bytes']!=x['bytes']or y['sha256']!=x['sha256']:changes.append(dict(before=x,after=y))
 image=new/'outflow/Ti60_Demo.hex';assert image.is_file()and image.stat().st_size>0
 raw=image.read_bytes();crc=f'{zlib.crc32(raw)&0xffffffff:08x}'
 textimage=raw.decode('ascii');lines=[s.strip()for s in textimage.splitlines()if s.strip()];assert lines and all(re.fullmatch(r'[0-9a-fA-F]+',s)for s in lines)
 outputs=[rec(q)for q in sorted((new/'outflow').iterdir())if q.is_file()and not(old/'outflow'/q.name).exists()]
 save(W/'INPUTS_POST.json',dict(canonical_sources=[rec(R/x['path'])for x in source],sealed_mirror=[rec(R/x['path'])for x in sealed],routed_db=[rec(R/x['path'])for x in db]))
 result=dict(status='PASS_OFFLINE_HEX_GENERATION_NO_HARDWARE',passed=True,running=False,owner=owner,log=rec(W/'native.log'),image=rec(image),crc32_file_bytes=crc,hex_ascii_lines=len(lines),hex_line_lengths=sorted(set(map(len,lines))),actual_new_outputs=outputs,copied_metadata_changes=changes,source_manifest=rec(O/'SOURCE_MANIFEST.json'),physical_receipt=rec(F/'FINAL_PHYSICAL_RECEIPT.json'),lbf=rec(old/'work_pnr/Ti60_Demo.lbf'),hardware_used=False,program_option_used=False,canonical_sources_unchanged=True,sealed_mirror_unchanged=True,routed_db_unchanged=True,tool_version='Efinity2025.1.110.5.9; see actual native log',git_commit=None)
 save(W/'RESULT.json',result);save(O/'pre_candidate/BITSTREAM_METADATA.json',result);print('STANDALONE_OFFLINE_IMAGE_PASS',json.dumps(result['image']),flush=True)
except Exception as e:
 save(W/'RESULT.json',dict(status='FAIL_OFFLINE_GENERATION_OR_METADATA_GATE',passed=False,running=False,error=repr(e)));print(repr(e),flush=True);raise
finally:
 save(O/'pre_candidate/ACTIVE_BIT_GENERATION.json',dict(path=W.relative_to(R).as_posix(),project=new.relative_to(R).as_posix(),manager_pid=os.getpid(),running=False,result=rec(W/'RESULT.json')if(W/'RESULT.json').exists()else None))
