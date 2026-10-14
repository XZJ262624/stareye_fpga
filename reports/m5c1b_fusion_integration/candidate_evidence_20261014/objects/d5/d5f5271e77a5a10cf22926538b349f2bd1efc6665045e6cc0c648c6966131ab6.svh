// Testbench-only source/UI/packet event ledger. No production driver.
 integer end_file,end_src_count=0,end_ui_count=0,end_start_count=0,end_done_count=0,end_take_count=0,end_ui_cycle=0;
 integer end_src_version=0,end_ui_version=0,end_pix_quiet=0,end_ui_quiet=0,end_pix_anchor=0,end_ui_anchor=0;
 integer end_target_src=0,end_target_ui=0,end_current_index=0,end_pending_take=0,end_payload_count=0,end_i;
 reg [63:0] end_target_seq=0,end_checked_seq=0;
 reg end_target_fixed=0,end_checked_healthy=0,end_finish_permitted=0,end_packet_active=0;
 reg [7:0] end_packet_type=0;
 reg [479:0] end_source_data[0:4095];reg [63:0] end_source_seq[0:4095],end_ui_seq[0:4095];
 integer end_done_cycle[0:4095],end_take_cycle[0:4095];
 reg [1:0] end_ui_idle_pix_sync=0,end_pix_idle_ui_sync=0;
