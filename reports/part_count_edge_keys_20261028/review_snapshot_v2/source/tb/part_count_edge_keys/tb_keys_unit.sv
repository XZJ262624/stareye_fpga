`timescale 1ns/1ps
module tb_keys_unit;
reg clk=0;always #5 clk=~clk;reg rst_n=0,ce=1,source_sof=0;reg [1:0] key_n=2;
wire ev,ef,view,changed,cf;wire [2:0] code;wire [7:0] hi;wire [63:0] gen;
part_keys_controls #(.DEBOUNCE_CYCLES(4),.LONG_CYCLES(40)) controls(.clk(clk),.arst_n(rst_n),.ce(ce),.sof(source_sof),.key_n(key_n),.event_valid(ev),.event_code(code),.event_fault(ef));
part_keys_config config_control(.clk(clk),.rst_n(rst_n),.ce(ce),.source_sof(source_sof),.event_valid(ev),.event_code(code),.high_threshold(hi),.generation(gen),.view(view),.changed(changed),.config_fault(cf));
integer events=0,last_code=0,i;reg [63:0] old_gen;reg [7:0] old_hi;
always @(posedge clk)if(rst_n&&ce&&ev)begin events=events+1;last_code=code;end
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task gesture(input [1:0] keys,input integer cycles,input integer want);integer old;begin old=events;key_n=keys;repeat(cycles)tick();key_n=3;repeat(14)tick();if(events!=old+1||last_code!=want)$fatal(1,"GESTURE events=%d code=%d want=%d",events,last_code,want);end endtask
task commit(input integer high,input integer generation_value,input integer v);begin
 source_sof=1;#1;if(hi!=high||gen!=generation_value||view!=v)$fatal(1,"SOF_EFFECTIVE_BYPASS hi=%d gen=%d view=%d",hi,gen,view);
 tick();source_sof=0;tick();if(hi!=high||gen!=generation_value||view!=v||cf||ef)$fatal(1,"SOF_ATOMIC");
end endtask
initial begin
 repeat(5)tick();rst_n=1;repeat(30)tick();key_n=3;repeat(20)tick();if(events||hi!=48||gen!=1)$fatal(1,"POWER_ON_HELD");
 key_n=2;tick();key_n=3;repeat(15)tick();if(events)$fatal(1,"BOUNCE");
 for(i=0;i<5;i=i+1)begin gesture(2,14,1);if(hi!=48-i*8)$fatal(1,"MIDFRAME_CHANGE");commit(40-i*8,2+i,0);end
 gesture(2,14,1);commit(8,6,0);gesture(2,100,1);commit(8,6,0);
 for(i=0;i<15;i=i+1)begin gesture(1,14,2);commit(16+i*8,7+i,0);end
 gesture(1,14,2);commit(128,21,0);
 gesture(0,14,3);commit(128,21,1);gesture(0,70,4);commit(128,21,1);
 // Overlapping keys and staggered release form one BOTH_SHORT only.
 i=events;key_n=2;repeat(12)tick();key_n=0;repeat(12)tick();key_n=1;repeat(12)tick();key_n=3;repeat(14)tick();
 if(events!=i+1||last_code!=3)$fatal(1,"STAGGERED_BOTH");commit(128,21,0);
 gesture(2,14,1);commit(120,22,0);gesture(1,14,2);commit(128,23,0);
 // CE freezes debounce, events and config. Held event must be consumed once.
 i=events;ce=0;key_n=2;repeat(30)tick();key_n=3;repeat(10)tick();ce=1;repeat(14)tick();if(events!=i)$fatal(1,"CE_PHANTOM");
 key_n=2;repeat(14)tick();key_n=3;while(!ev)tick();ce=0;old_hi=hi;old_gen=gen;source_sof=1;repeat(15)tick();
 if(hi!=old_hi||gen!=old_gen||events!=i)$fatal(1,"CE_FREEZE");source_sof=0;ce=1;tick();repeat(12)tick();if(events!=i+1)$fatal(1,"CE_EVENT_ONCE");commit(120,24,0);
 $display("PASS_KEYS_UNIT events=%0d startup bounce continuous_short saturation ABA staggered double_short_long CE SOF_atomic",events);$finish;
end
initial begin repeat(15000)@(posedge clk);$fatal(1,"UNIT_WATCHDOG");end
endmodule
