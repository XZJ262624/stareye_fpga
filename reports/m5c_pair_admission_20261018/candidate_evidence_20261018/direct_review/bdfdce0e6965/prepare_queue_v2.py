from pathlib import Path
R=Path.cwd()
s=(R/'tb/m5c_pair_diag/tb_pair_latest_queue.sv').read_text().replace('module tb_pair_latest_queue;','module tb_pair_latest_queue_v2;')
s=s.replace('m5c_pair_capture #(.WIDTH(200),.HEIGHT(8))','wire [1:0] cap_reset_done;wire [3:0] cap_fifo_faults;\n m5c_pair_capture #(.WIDTH(200),.HEIGHT(8),.SEPARATE_ELIGIBILITY(1))')
s=s.replace('.identity_ok(1\'b1),','.identity_ok(1\'b1),.capture_eligible(1\'b1),')
s=s.replace('.data(cap_data),.empty(cap_empty),.pop(cap_pop),.count(cap_count));','.data(cap_data),.empty(cap_empty),.pop(cap_pop),.count(cap_count),.reset_done(cap_reset_done),.fifo_faults(cap_fifo_faults));')
s=s.replace('if(cap_arm)begin first_arm_cycle=', 'if(cap_arm&&cap_reset_done!==2\'b11)$fatal(1,"CAPTURE_RESET_NOT_RELEASED");\n  if(cap_reset_done==2\'b11&&cap_fifo_faults!==0)$fatal(1,"CAPTURE_FIFO_FAULT");\n  if(cap_arm)begin first_arm_cycle=')
p=R/'tb/m5c_pair_diag/tb_pair_latest_queue_v2.sv';assert not p.exists();p.write_text(s)
for name in ['queue','queue_negative']:
 s=(R/f'scripts/m5c_pair_latest_{name}.py').read_text().replace('tb_pair_latest_queue','tb_pair_latest_queue_v2').replace("'queue_'","'queue_v2_'").replace("'queue_mutant_'","'queue_v2_mutant_'")
 p=R/f'scripts/m5c_pair_latest_{name}_v2.py';assert not p.exists();p.write_text(s)
