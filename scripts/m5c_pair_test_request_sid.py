from pathlib import Path
import re,json,hashlib,datetime,subprocess,time
R=Path.cwd();W=R/'reports/m5c_pair_capture_20261016'/('request_sid_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir();M=Path('E:/Modelsim_10.1c/win64')
backend=R/'rtl/m5c_pair_diag/m5c_pair_backend.sv';system=R/'rtl/m5c_pair_diag/m5c_pair_system.sv';mailbox=R/'rtl/m5c_fusion/m5b1_mailbox.sv'
b=backend.read_text();s=system.read_text();select=re.search(r' assign pair_selected=.*?;',b,re.S)[0];take=re.search(r' assign pair_request_take=.*?;',b,re.S)[0];send=re.search(r'wire pair_send=.*?;',s)[0]
tb='''`timescale 1ns/1ps
module tb_pair_request_sid;
reg pix_clk=0,ui_clk=0,rst_n=0;always #7 pix_clk=~pix_clk;always #5 ui_clk=~ui_clk;
reg fusion_request=0,pair_cov=1,pair_wait_expired_pix=0;reg [1:0] pair_terminal_pix=0;
reg [63:0] fusion_request_seq=0,pair_session=0;
wire pair_request,pair_request_busy,pair_request_take,pair_selected;wire [63:0] pair_request_session;
reg fusion_acquire=0;wire exported=1;wire [767:0] active_pair_descriptor=768'h100000000000000000000000000000000,result_descriptor=active_pair_descriptor;
wire [63:0] pair_export_job_floor=0,pair_last_selected_job=0;
wire pair_terminal=0,pair_hold=0,tx_busy=0,eng_busy=0,arm_busy=0,writer_owned=0,uart_owned=0,packet_busy=0,packet_start=0,stop=0,pair_wait_expired=0;
localparam IDLE=0;wire [4:0] state=IDLE;
'''+send+'\n'+select+'\n'+take+'''
m5b1_mailbox #(.WIDTH(64)) mb(.sclk(pix_clk),.dclk(ui_clk),.arst_n(rst_n),.send(pair_send),.sdata(fusion_request_seq),.busy(pair_request_busy),.valid(pair_request),.ddata(pair_request_session),.take(pair_request_take));
task sendreq(input [63:0] sid);begin @(negedge pix_clk);fusion_request_seq=sid;fusion_request=1;@(negedge pix_clk);fusion_request=0;end endtask
task acquire(input [63:0] sid,input expected);begin @(negedge ui_clk);pair_session=sid;fusion_acquire=1;#1;if(pair_selected!==expected)$fatal(1,"SID_SELECTION_MISMATCH sid=%h request=%h selected=%b",sid,pair_request_session,pair_selected);@(negedge ui_clk);fusion_acquire=0;end endtask
task drain;begin wait(!pair_request);wait(!pair_request_busy);repeat(3)@(negedge pix_clk);end endtask
initial begin
 repeat(5)@(negedge pix_clk);rst_n=1;repeat(8)@(negedge pix_clk);
 // Early complete request stays pending until the corresponding real acquire.
 sendreq(64'h100000005);wait(pair_request);repeat(4)@(negedge ui_clk);if(pair_request_take)$fatal(1,"FUTURE_REQUEST_DROPPED");
 acquire(64'h100000005,1);drain;
 // Same low32 but different high32 never selects; stale request drains.
 sendreq(64'h100000009);wait(pair_request);acquire(64'h200000009,0);drain;
 // Late old request after the active session passed must not retain busy forever.
 sendreq(64'h100000006);wait(pair_request);#1;if(!pair_request_take||pair_selected)$fatal(1,"LATE_REQUEST_NOT_DISCARDED");drain;
 // busy send is not accepted and cannot overwrite held64.
 sendreq(64'h30000000a);wait(pair_request);sendreq(64'h40000000a);if(pair_request_session!==64'h30000000a)$fatal(1,"BUSY_OVERWROTE_SID");
 acquire(64'h30000000a,1);drain;
 // First available valid request and acquire on the next destination edge.
 sendreq(64'h40000000b);wait(pair_request);acquire(64'h40000000b,1);drain;
 // A non-COV request creates no diagnostic request.
 pair_cov=0;sendreq(64'h50000000c);repeat(15)@(negedge ui_clk);if(pair_request||pair_request_busy)$fatal(1,"NONCOV_REQUEST_SENT");
 $display("PAIR_REQUEST_SID_PASS early_same_late_high32_busy_noncov");$finish;
end
initial begin #100000;$fatal(1,"SID_TEST_WATCHDOG");end
endmodule
'''
(W/'tb_pair_request_sid.sv').write_text(tb);rows=[]
for p in [backend,system,mailbox]:
 q=W/p.name;q.write_bytes(p.read_bytes());rows.append(dict(path=str(p),snapshot=str(q),sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
(W/'INPUTS.json').write_text(json.dumps(rows,indent=2));(W/'RUNNER.py').write_bytes(Path(__file__).read_bytes())
for n,args in [('lib',[str(M/'vlib.exe'),'work']),('compile',[str(M/'vlog.exe'),'-sv',str(W/mailbox.name),str(W/'tb_pair_request_sid.sv')]),('sim',[str(M/'vsim.exe'),'-c','-novopt','-l',str(W/'native.log'),'-wlf',str(W/'native.wlf'),'work.tb_pair_request_sid','-do','run -all;quit -f'])]:
 with (W/(n+'.log')).open('w') as f:
  p=subprocess.Popen(args,cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/(n+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,command=args,time=time.time())));c=p.wait()
 t=(W/(n+'.log')).read_text();assert c==0 and '** Error' not in t and '** Fatal' not in t,t
assert 'PAIR_REQUEST_SID_PASS' in t
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_REAL_MAILBOX_SOURCE_DERIVED_SELECTION_UNIT',scope='Exact current backend select/take and system send expressions, real64mailbox; other admission predicates held true. Not complete backend/video proof.',source_unchanged=all(hashlib.sha256(Path(r['path']).read_bytes()).hexdigest()==r['sha256'] for r in rows)),indent=2));print(W)
