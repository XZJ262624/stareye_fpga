from pathlib import Path
import subprocess,hashlib,json
R=Path('F:/Projects/stareye_fpga');F=Path(__file__).resolve().parent;F.mkdir(exist_ok=True)
old=subprocess.check_output(['git','-c','safe.directory=F:/Projects/stareye_fpga','show','99ea359c6a5f5432296e992ec76495e441c9d1a0:rtl/m5c_pair_diag/m5c_pair_backend.sv'],cwd=R)
assert old==(R/'rtl/m5c_pair_diag/m5c_pair_backend.sv').read_bytes();(F/'backend_99ea.sv').write_bytes(old)
base=R/'tb/m5c_pair_diag/tb_pair_latest_queue_v2.sv';s=base.read_text();s=s.replace('tb_pair_latest_queue_v2','tb_pair_deadline')
s=s.replace('reg queue_hold=0;','reg deadline_arm=0,deadline_latched=0; wire expired=deadline_latched||(deadline_arm&&fusion_acquire); always @(posedge clk)if(rst_n&&expired)deadline_latched<=1;\n reg queue_hold=0;')
assert s.count('.pair_wait_expired(1\'b0)')==1;s=s.replace('.pair_wait_expired(1\'b0)','.pair_wait_expired(expired)')
start=s.index(' integer stale_ack=0;');end=s.index(' initial begin #500000000;',start)
s=s[:start]+''' always @(posedge clk)if(rst_n&&expired&&backend.pair_selected)$fatal(1,"DEADLINE_NEW_SELECT_AFTER_EXPIRY");
 initial begin
  wait(rst_n);wait(pubs==1&&backend.state==backend.IDLE&&!backend.packet_busy);
  @(negedge clk);queue_hold=1;
  pulse(1,1);wait(ds.req_valid);wait(backend.pair_latest_request_valid&&backend.pair_latest_request_session==7);wait(!pair_busy);
  repeat(8)@(negedge clk);
  if(pubs!=1||selected||backend.pair_attempts||!backend.fresh_publication_seen)$fatal(1,"DEADLINE_PRECONDITION");
  deadline_arm=1;queue_hold=0;
  wait(acks==1);repeat(8)@(negedge pix);
  @(negedge pix);pixel_release=1;@(negedge pix);pixel_release=0;
  wait(pair_completed==1);wait(!backend.pair_hold&&pair_leased==0);repeat(10)@(negedge clk);
  if(selected||arm_count||backend.pair_attempts||backend.pair_failure!=23||!backend.fresh_publication_seen||!backend.pair_terminal)$fatal(1,"DEADLINE_SAFE_FAILURE_NOT_CLOSED");
  $display("DEADLINE_PASS case=%0d acks=%0d selected=%0d attempts=%0d reason=%0d",CASE,acks,selected,backend.pair_attempts,backend.pair_failure);$fclose(events);$fclose(uart_file);$finish;
 end
'''+s[end:]
(F/'tb_pair_deadline.sv').write_text(s)
r=(R/'scripts/m5c_pair_latest_queue_v2.py').read_text();r=r.replace("R=Path(__file__).resolve().parents[1];F=R/'reports/m5c_pair_admission_20261018/implementation'","R=Path('F:/Projects/stareye_fpga');F=Path(__file__).resolve().parent")
r=r.replace("('queue_v2_'","('old_repro_'").replace("tb=R/'tb/m5c_pair_diag/tb_pair_latest_queue_v2.sv'","tb=F/'tb_pair_deadline.sv'")
r=r.replace("inputs=[rec(p) for p in sources+", "sources=[F/'backend_99ea.sv' if p.name=='m5c_pair_backend.sv' else p for p in sources]\ninputs=[rec(p) for p in sources+")
r=r.replace('work.tb_pair_latest_queue_v2','work.tb_pair_deadline').replace('for c in [0,1]','for c in [0]')
r=r.replace("ok=code==0 and '** Error' not in text and '** Fatal' not in text and (stage in ('vlib','compile') or 'LATEST_QUEUE_PASS' in text)","ok=code==0 and '** Error' not in text and (('** Fatal' not in text) if stage in ('vlib','compile') else (text.count('** Fatal: DEADLINE_NEW_SELECT_AFTER_EXPIRY')==1 and text.count('** Fatal:')==1))")
r=r.replace("'PASS_LATEST_QUEUE'","'PASS_EXPECTED_99EA_DEADLINE_DEFECT'")
(F/'run_old.py').write_text(r)
(F/'DERIVATION_OLD.json').write_text(json.dumps(dict(parent='99ea359c6a5f5432296e992ec76495e441c9d1a0',backend_sha256=hashlib.sha256(old).hexdigest(),base_tb=str(base),scope='Actual backend/cache/session/dual mailbox acquire. Expiry asserted at backend input same acquire edge, no system synchronizer claim. Original capture/transfer/arbiter/telemetry remain real.'),indent=2))
