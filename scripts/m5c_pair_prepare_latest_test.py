from pathlib import Path
R=Path.cwd();O=R/'reports/m5c_pair_capture_20261016/latest_descriptor_test_preparation';O.mkdir(exist_ok=False)
ins='''.clk(clk),.rst_n(rst),.stop(stop),.export_exclusive(1'b0),
.reserve_valid(reserve),.reserve_identity(id),.bind_valid(bindv),.bind_slot(slot),.bind_identity(id),
.publish_valid(pub),.publish_slot(slot),.metadata_b_done(meta),.publish_identity(pubid),
.cancel_valid(cancel),.cancel_slot(slot),.write_drained(drained),.cancel_identity(id),
.acquire_valid(acq),.acquire_slot(slot),.acquire_uart(1'b0),.acquire_identity(id),.acquire_token(token),
.release_valid(rel),.release_slot(rel_slot),.release_uart(1'b0),.release_identity(rel_id),.release_token(rel_token),
.retire_valid(ret),.retire_slot(rel_slot),.retire_uart(1'b0),.retire_identity(rel_id),.retire_token(rel_token),
.read_accept(1'b0),.read_slot(slot),.read_uart(1'b0),.read_identity(id),.read_token(token),
.read_done(bad_done),.done_slot(slot),.done_uart(1'b0),.done_identity(id),.done_token(token)'''
outs={'reserve_ack':'ra','reserve_denied':'rd','reserve_slot':'rs','bind_ack':'ba','acquire_ack':'aa','acquire_denied':'ad','latest_valid':'lv','latest_slot':'ls','reserved':'writing','committed':'ready','leased':'held','protocol_fault':'fault','event_rejected':'reject'}
tb='''`timescale 1ns/1ps
module tb_pair_latest_descriptor;
reg clk=0;always #5 clk=~clk;
reg rst=0,stop=0,reserve=0,bindv=0,pub=0,meta=1,cancel=0,drained=0,acq=0,rel=0,ret=0,bad_done=0;
reg slot=0,rel_slot=0;reg [319:0] id=0,pubid=0,rel_id=0;reg [63:0] token=0,rel_token=0;
reg [767:0] descriptor=0,oldslot[0:1],latest=0;wire accept;
integer events=0,edges=0,k,j;reg preaccept;
'''
for suffix in ['a','b']:
 tb+='wire '+','.join(v+suffix for v in ['ra','rd','rs','ba','aa','ad','lv','ls','fault','reject'])+';\nwire [1:0] writing'+suffix+',ready'+suffix+';wire [3:0] held'+suffix+';\n'
 tb+=('m5c_pair_lease old_core' if suffix=='a' else 'm5c_pair_diag_lease new_core')+'('+ins+','+','.join('.'+p+'('+v+suffix+')' for p,v in outs.items())+('' if suffix=='a' else ',.publication_accept(accept)')+');\n'
tb+='''
always @(posedge clk)begin
 preaccept=accept;
 if(!rst)begin oldslot[0]<=0;oldslot[1]<=0;latest<=0;end
 else if(accept)begin oldslot[slot]<=descriptor;latest<=descriptor;events=events+1;end
 #1;
 if({raa,rda,rsa,baa,aaa,ada,lva,lsa,writinga,readya,helda,faulta,rejecta}!=={rab,rdb,rsb,bab,aab,adb,lvb,lsb,writingb,readyb,heldb,faultb,rejectb})$fatal(1,"LEASE_PORT_DIFFERENCE");
 if({old_core.halted,old_core.bound,old_core.cancelling}!=={new_core.halted,new_core.bound,new_core.cancelling})$fatal(1,"LEASE_CONTROL_DIFFERENCE");
 for(k=0;k<2;k=k+1)begin
 if(old_core.identity[k]!==new_core.identity[k])$fatal(1,"LEASE_IDENTITY_DIFFERENCE");
 for(j=0;j<2;j=j+1)if({old_core.held[k][j],old_core.pending[k][j],old_core.cache[k][j],old_core.reads[k][j],old_core.token[k][j]}!=={new_core.held[k][j],new_core.pending[k][j],new_core.cache[k][j],new_core.reads[k][j],new_core.token[k][j]})$fatal(1,"LEASE_OWNER_DIFFERENCE");
 end
 if(lva&&latest!==oldslot[lsa])$fatal(1,"LATEST_DESCRIPTOR_DIFFERENCE");
 edges=edges+1;
end
task resetcore;begin @(negedge clk);rst=0;stop=0;reserve=0;bindv=0;pub=0;meta=1;cancel=0;drained=0;acq=0;rel=0;ret=0;bad_done=0;repeat(3)@(negedge clk);rst=1;end endtask
task reservejob(input [63:0] gen);begin
 id={64'h1111222233334444,gen,64'h5555666677778888,64'h123456789abcdef0,gen};pubid=id;token=gen+64'hfedc000000000000;
 descriptor={id,id,token,gen};reserve=1;@(negedge clk);reserve=0;if(!raa)$fatal(1,"RESERVE_FAILED");slot=rsa;
end endtask
task bindjob;begin bindv=1;@(negedge clk);bindv=0;if(!baa)$fatal(1,"BIND_FAILED");end endtask
task publishcheck(input want);begin pub=1;#1;if(accept!==want)$fatal(1,"PUBLICATION_ACCEPT_WRONG expected=%b actual=%b",want,accept);@(negedge clk);pub=0;end endtask
initial begin
 resetcore;reservejob(64'h100000001);bindjob;acq=1;publishcheck(1);acq=0;if(!aaa||helda==0)$fatal(1,"SAME_EDGE_PUBLISH_ACQUIRE");
 rel_slot=slot;rel_id=id;rel_token=token;
 // Other slot publication while the old consumer still owns the old identity.
 reservejob(64'h200000002);bindjob;publishcheck(1);if(helda==0)$fatal(1,"OLD_OWNER_LOST");
 rel=1;ret=1;@(negedge clk);rel=0;ret=0;if(helda!=0)$fatal(1,"OLD_OWNER_NOT_DRAINED");
 reservejob(64'h300000003);bindjob;publishcheck(1);
 // Cancellation wins, leaves previous latest tuple unchanged, then drain permits recovery.
 reservejob(64'h400000004);bindjob;cancel=1;publishcheck(0);cancel=0;drained=1;@(negedge clk);drained=0;
 reservejob(64'h500000005);bindjob;publishcheck(1);
 resetcore;reservejob(64'h600000006);publishcheck(0);bindjob;meta=0;publishcheck(0);meta=1;
 pubid=id^320'h100000000000000000000000000000000000000000000000000000000000000000000000001;publishcheck(0);pubid=id;publishcheck(1);
 resetcore;reservejob(64'h700000007);bindjob;stop=1;publishcheck(0);stop=0;publishcheck(0);
 resetcore;reservejob(64'h800000008);bindjob;bad_done=1;@(negedge clk);bad_done=0;if(!faulta)$fatal(1,"FAULT_SETUP");publishcheck(0);
 resetcore;reservejob(64'h900000009);bindjob;publishcheck(1);
 $display("PAIR_LATEST_DESCRIPTOR_PASS events=%0d edges=%0d full768_full320",events,edges);$finish;
end
initial begin #100000;$fatal(1,"LATEST_TEST_WATCHDOG");end
endmodule
'''
(R/'tb/m5c_pair_diag/tb_pair_latest_descriptor.sv').write_text(tb)
(O/'SCOPE.txt').write_text('Original core versus clone all public outputs and all original state arrays each edge; two-slot descriptor reference updates only on actual accepted publication, not arbitrary invalid backend publication requests. All source semantics scope explicit; no entire backend equivalence claim.')
