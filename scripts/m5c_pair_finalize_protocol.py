import json
from pathlib import Path
p=Path('reports/m5c_pair_capture_20261016/PROTOCOL.json');a=json.loads(p.read_text());a['packet_types'].update({'7':230424,'8':115224,'9':921624});a['plane_prefix']={'bytes':24,'fields':['capture_id u64 LE','session u64 LE','token u64 LE'],'counted_in_payload':True,'plane_data_bytes_unchanged':True};a['total_wire_bytes']=1268380;a['success']+='; each plane24B prefix exact capture_id/session/token equals metadata and completion';p.write_text(json.dumps(a,indent=2)+'\n')
