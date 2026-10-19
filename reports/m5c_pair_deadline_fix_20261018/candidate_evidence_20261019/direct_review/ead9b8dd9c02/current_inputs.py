"""V4 prospective evidence only: measure actual current working inputs, never historical hashes."""
from pathlib import Path
import json,hashlib,time
def identity(path):
 b=Path(path).read_bytes();return dict(size=len(b),sha256=hashlib.sha256(b).hexdigest())
def capture(root,label,phase,tool):
 root=Path(root);manifest=json.loads((root/'manifest.json').read_text());original=json.loads((root/'provenance/ORIGINAL_63_INPUTS.json').read_text())
 names=[x['path'] for x in original];assert len(names)==63 and len(set(names))==63
 records=[]
 for name in names:
  p=(root/name).resolve();assert p.is_relative_to(root.resolve());actual=identity(p);assert actual==manifest['files'][name],('CURRENT_INPUT_CHANGED',name)
  records.append(dict(path=str(p),relative_path=name,bytes=actual['size'],sha256=actual['sha256']))
 result=dict(schema=1,label=label,phase=phase,measured_unix=time.time(),manifest=identity(root/'manifest.json'),tool=tool,records=records,source='actual current working bytes checked against current manifest; historical original hash fields not used')
 out=root/('CURRENT_INPUTS_'+label.upper()+'_'+phase.upper()+'.json');assert not out.exists(),out
 if phase=='post':
  pre=json.loads((root/('CURRENT_INPUTS_'+label.upper()+'_PRE.json')).read_text());assert pre['records']==records and pre['manifest']==result['manifest'] and pre['tool']==tool,('PRE_POST_CHANGED',label)
 out.write_text(json.dumps(result,indent=2)+'\n');return result
