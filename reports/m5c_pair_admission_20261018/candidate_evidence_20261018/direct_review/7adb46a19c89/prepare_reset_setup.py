from pathlib import Path
R=Path.cwd();s=(R/'tb/m5c_pair_diag/tb_pair_latest_edges_v2.sv').read_text().replace('module tb_pair_latest_edges_v2;','module tb_pair_latest_edges_v3;')
a='if(CASE==3)begin pulse(0,1);';b='if(CASE==3)begin wait(!pair_busy);repeat(3)@(negedge pix);pulse(0,1);';assert s.count(a)==1;s=s.replace(a,b)
p=R/'tb/m5c_pair_diag/tb_pair_latest_edges_v3.sv';assert not p.exists();p.write_text(s)
s=(R/'scripts/m5c_pair_latest_edges_v2.py').read_text().replace('tb_pair_latest_edges_v2','tb_pair_latest_edges_v3').replace("'edges_v2_'","'edges_v3_'").replace('for c in [2,3,4]','for c in [3,4]')
p=R/'scripts/m5c_pair_latest_edges_v3.py';assert not p.exists();p.write_text(s)
