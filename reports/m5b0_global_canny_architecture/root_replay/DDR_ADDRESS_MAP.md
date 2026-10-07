# DDR候选地址图（半开字节区间）

计算检查PASS不等于DDR高位解码/硬件读回PASS。新增安全地址实际确认量为0；所有M5B地址均为待验证候选。4MiB视频槽尾整体禁止复用。

|用途/缓冲|[start, end)|字节数|对齐B|格式|权限|状态|
|---|---|---:|---:|---|---|---|
|video_0_payload|[0x00000000, 0x000E1000)|921600|2048|8-bit grayscale; 16 pixels/AXI beat|RW|existing|
|video_0_slot_tail_FORBIDDEN|[0x000E1000, 0x00400000)|3272704|2048|reserved full existing 4 MiB slot|NONE for M5B|forbidden|
|video_1_payload|[0x00400000, 0x004E1000)|921600|2048|8-bit grayscale; 16 pixels/AXI beat|RW|existing|
|video_1_slot_tail_FORBIDDEN|[0x004E1000, 0x00800000)|3272704|2048|reserved full existing 4 MiB slot|NONE for M5B|forbidden|
|video_2_payload|[0x00800000, 0x008E1000)|921600|2048|8-bit grayscale; 16 pixels/AXI beat|RW|existing|
|video_2_slot_tail_FORBIDDEN|[0x008E1000, 0x00C00000)|3272704|2048|reserved full existing 4 MiB slot|NONE for M5B|forbidden|
|video_3_payload|[0x00C00000, 0x00CE1000)|921600|2048|8-bit grayscale; 16 pixels/AXI beat|RW|existing|
|video_3_slot_tail_FORBIDDEN|[0x00CE1000, 0x01000000)|3272704|2048|reserved full existing 4 MiB slot|NONE for M5B|forbidden|
|classification_A|[0x01000000, 0x01038400)|230400|16|2 bit/pixel, low x in low bits|RW only assigned owner|candidate_unqualified|
|classification_A_alignment_hole|[0x01038400, 0x01039000)|3072|16|padding|NONE|padding|
|classification_B|[0x01039000, 0x01071400)|230400|16|2 bit/pixel, low x in low bits|RW only assigned owner|candidate_unqualified|
|classification_B_alignment_hole|[0x01071400, 0x01072000)|3072|16|padding|NONE|padding|
|work_A|[0x01072000, 0x0108E200)|115200|16|1 bit/pixel, low x in low bits|RW only assigned owner|candidate_unqualified|
|work_A_alignment_hole|[0x0108E200, 0x0108F000)|3584|16|padding|NONE|padding|
|work_B|[0x0108F000, 0x010AB200)|115200|16|1 bit/pixel, low x in low bits|RW only assigned owner|candidate_unqualified|
|work_B_alignment_hole|[0x010AB200, 0x010AC000)|3584|16|padding|NONE|padding|
|result_A|[0x010AC000, 0x010C8200)|115200|16|1 bit/pixel, low x in low bits|RW only assigned owner|candidate_unqualified|
|result_A_alignment_hole|[0x010C8200, 0x010C9000)|3584|16|padding|NONE|padding|
|result_B|[0x010C9000, 0x010E5200)|115200|16|1 bit/pixel, low x in low bits|RW only assigned owner|candidate_unqualified|
|result_B_alignment_hole|[0x010E5200, 0x010E6000)|3584|16|padding|NONE|padding|
|metadata_status|[0x010E6000, 0x010E7000)|4096|4096|versioned 4 KiB page, 128-bit words|RW controller only|candidate_unqualified|
|unallocated_configured_capacity_FORBIDDEN|[0x010E7000, 0x20000000)|519147520|4096|unqualified/unallocated|NONE|forbidden|
|outside_configured_capacity_FORBIDDEN|[0x20000000, 0x100000000)|3758096384|4096|possible address alias / out of configured device|NONE|forbidden|

每张分类图行步长320B、共230400B，每张1b图行步长160B、共115200B；均精确16B拍对齐。槽分配按4KiB上取整，尾孔禁止业务写入。burst planner采用最大128拍、帧末短burst且切断4KiB边界，不能直接重用旧控制器固定128拍的帧尾逻辑。生命周期见 BUFFER_OWNERSHIP_AND_CDC.md；各候选图只允许登记的唯一写者。
地址证据、尚未证明的高位别名/跨bank映射及端口限制见 DDR_SOURCE_AUDIT.md。JSON为审计数据，不是生产RTL参数。
