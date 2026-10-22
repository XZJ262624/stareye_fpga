from common import *
import difflib,xml.etree.ElementTree as ET
T=R/'rtl/canny_gaussian_standalone';parents=json.loads((O/'PARENT_SOURCE_MANIFEST.json').read_text());verify(parents)
sources=[p for d in [T,P] for p in sorted(d.rglob('*')) if p.is_file() and not any(x.startswith(('work_','outflow','__pycache__')) for x in p.relative_to(d).parts) and p.suffix in ('.v','.sv','.vh','.svh','.xml','.sdc','.json','.bin')]
save(O/'SOURCE_MANIFEST.json',[rec(p) for p in sources])
delta=[]
origin={T/'core/canny_backend.sv':R/'rtl/gaussian_integration/pair/m5c_pair_backend.sv',T/'core/canny_system.sv':R/'rtl/gaussian_integration/shape/shape_pair_system_guard.sv',T/'core/canny_osd.sv':R/'rtl/gaussian_integration/shape/shape_osd.sv',P/'example_top.v':R/'efinity/gaussian_shape_cap_i3/example_top.v',P/'src/cmos_i2c/I2C_AR0135_1280720_Config.v':R/'efinity/gaussian_shape_cap_i3/src/cmos_i2c/I2C_AR0135_1280720_Config.v',P/'Ti60_Demo.xml':R/'efinity/gaussian_shape_cap_i3/Ti60_Demo.xml',P/'Ti60_Demo_I3.sdc':R/'efinity/gaussian_shape_cap_i3/Ti60_Demo_I3.sdc'}
for p in sources:
 if p in origin:parent=origin[p]
 elif p.is_relative_to(T/'core'):parent=R/'rtl/gaussian_integration/pair'/p.name
 elif p.is_relative_to(T):parent=R/'rtl/gaussian_integration'/p.relative_to(T)
 else:parent=R/'efinity/gaussian_shape_cap_i3'/p.relative_to(P)
 if parent.exists():
  same=p.read_bytes()==parent.read_bytes();delta.append(dict(source=rec(parent),child=rec(p),identical=same))
save(O/'DERIVATION_MANIFEST.json',delta)
diff=''
for p,parent in origin.items():diff+=''.join(difflib.unified_diff(parent.read_text().splitlines(True),p.read_text().splitlines(True),fromfile=parent.relative_to(R).as_posix(),tofile=p.relative_to(R).as_posix()))+'\n'
(O/'FOCUSED_TECHNICAL_DIFF.patch').write_text(diff,encoding='utf8')
compiled=[Path(n.attrib['name']) for n in ET.parse(P/'Ti60_Demo.xml').getroot().iter() if n.tag.endswith('}design_file')]
assert all(p in sources for p in compiled);assert len(compiled)==len(set(compiled))
save(O/'ACTUAL_COMPILE_CLOSURE.json',dict(files=[rec(p) for p in compiled],ip_inputs=[rec(p) for p in sources if p.is_relative_to(P/'ip')],includes=[rec(p) for p in (T/'m5c').glob('*.vh')]))
print('SOURCE_MANIFEST',len(sources),'COMPILE',len(compiled),'UNCHANGED_DERIVATIONS',sum(x['identical'] for x in delta))
