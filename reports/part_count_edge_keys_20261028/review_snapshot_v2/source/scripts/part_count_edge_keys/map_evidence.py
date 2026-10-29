from physical_common import *
a=json.loads((O/'ACTIVE_PHYSICAL.json').read_text());F=R/a['path'];B=R/a['project'];p=B/'outflow/Ti60_Demo.map.v'
raw=re.sub(r'/\*.*?\*/','',p.read_text().split('endmodule',1)[0],flags=re.S)
ffs={}
for m in re.finditer(r'^    (EFX_FF)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',raw,re.M|re.S):
 name=m[2].lstrip('\\');cl=re.search(r'\.CLK\s*\((.*?)\)',m[3],re.S)
 if cl:ffs[name]=cl[1].strip()
selected={k:v for k,v in ffs.items() if any(t in k for t in ('u_shape_system/config_control/','u_shape_system/u_part_adapter/','u_shape_system/u_part_core/cfg['))}
assert selected and set(selected.values())=={'clk_pixel'},set(selected.values())
gens=[f'u_shape_system/config_control/active_generation[{n}]~FF' for n in range(64)]
assert all(k in ffs and ffs[k]=='clk_pixel' for k in gens)
sdc=R/'efinity/part_count_edge_keys_i3/Ti60_Demo_I3.sdc';old=R/'efinity/part_count_edge_open_i3/Ti60_Demo_I3.sdc';assert sdc.read_bytes()==old.read_bytes()
exact=json.loads((F/'EXACT_CDC_SELECTOR_STATIC.json').read_text());assert exact['passed'] and len(exact['groups'])==19
save(O/'NEW_CONFIG_CLOCK_PROOF.json',dict(passed=True,generation_bits=64,new_config_domain='clk_pixel',checked_flops=selected,SDC_same_as_parent=True,sdc=rec(sdc),map=rec(p),existing_exact_CDC_groups=19,scope='Only new config controller, adapter tag flops and core config identity; no all-FF or all-clock-pair audit.'))
print('NEW_CONFIG_CLOCK_PROOF_PASS',len(selected))
