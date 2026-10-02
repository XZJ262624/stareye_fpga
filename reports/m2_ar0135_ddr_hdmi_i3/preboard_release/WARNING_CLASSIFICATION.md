# M2最终批次告警逐条处置

2026-10-03；主会话逐项核对。原始warn.log最后批次从623行开始；303条记录，另1条“100 warnings”网表汇总。不是403个独立问题。分类中的“必须修复”包含必须先澄清的条目，未澄清不等于已经证实电路故障。厂商旧镜像实测出图，不证明当前DDR v5.14/FIFO迁移后的所有告警无害。

|分类|记录数|
|---|---:|
|必须修复|34|
|已知IP噪声|44|
|需要实物验证|28|
|与当前设计无关|197|

证据：final_build/Ti60_Demo.warn.log；SHA256 F7D6AFD1AC3CA0913608F665551C0EBDFAF8311F33F486D5D292CE66E70F2564。预/后综合的重复记录保留。20条EFX-0200、10条EFX-0201、147条EFX-0256、126条EFX-0011。

接口提示独立归档于RELEASE_REVIEW.md；未自动压制任何告警。

|编号|原日志行|代码|分类|原文及理由|
|---|---:|---|---|---|
|W001|627|EFX-0011|需要实物验证|[EFX-0011 VERI-WARNING] port 'cal_shift_val' remains unconnected for this instance (VERI-1927) (example_top.v:598)<br>校准移位观测口未接；不影响输出连接本身，需另验cal_pass、lane及重复校准|
|W002|628|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] port 'i2c_rdata' remains unconnected for this instance (VERI-1927) (example_top.v:671)<br>SC130GS/CSI控制器的读回口；非AR0135控制器，CSI外设未启用|
|W003|629|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] port 'axi_awid' remains unconnected for this instance (VERI-1927) (example_top.v:996)<br>未消费的AWID输出；该发生器固定ID=0，低宽ID风险另列|
|W004|630|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] port 'lcd_xpos' remains unconnected for this instance (VERI-1927) (example_top.v:1023)<br>LCD坐标诊断口未消费；实际视频走lcd_rgb|
|W005|631|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] port 'TMDS_Clk_p' remains unconnected for this instance (VERI-1927) (example_top.v:1069)<br>ENABLE_OSERDES=0，原生LVDS接口产生时钟，不使用旧TMDS_Clk_p|
|W006|632|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] expression size 32 truncated to fit in target size 1 (VERI-1209) (example_top.v:429)<br>遗留Flash/外设控制变量的1位赋值；不是配置Flash操作证据|
|W007|633|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] port 'wr_busy' remains unconnected for this instance (VERI-1927) (ip/DdrCtrl\DdrCtrl.sv:184)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W008|634|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] port 'wr_data' is not connected on this instance (VERI-2435) (ip/DdrCtrl\DdrCtrl.sv:184)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W009|635|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] port '**' is not connected on this instance (VERI-2435) (ip/DdrCtrl\DdrCtrl.sv:2496)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W010|636|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] expression size ** truncated to fit in target size ** (VERI-1209) (ip/DdrCtrl\DdrCtrl.sv:2611)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W011|637|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] actual bit length ** differs from formal bit length *** for port '**' (VERI-1330) (ip/DdrCtrl\DdrCtrl.sv:2496)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W012|638|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] expression size ** truncated to fit in target size ** (VERI-1209) (ip/DdrCtrl\DdrCtrl.sv:2611)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W013|639|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] expression size ** truncated to fit in target size ** (VERI-1209) (ip/DdrCtrl\DdrCtrl.sv:2611)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W014|640|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] actual bit length ** differs from formal bit length *** for port '**' (VERI-1330) (ip/DdrCtrl\DdrCtrl.sv:2496)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W015|641|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] port '**' remains unconnected for this instance (VERI-1927) (ip/DdrCtrl\DdrCtrl.sv:590)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W016|642|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] actual bit length ** differs from formal bit length *** for port '**' (VERI-1330) (ip/DdrCtrl\DdrCtrl.sv:590)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W017|643|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] port '**' remains unconnected for this instance (VERI-1927) (ip/DdrCtrl\DdrCtrl.sv:1460)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W018|644|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] port '**' remains unconnected for this instance (VERI-1927) (ip/DdrCtrl\DdrCtrl.sv:4817)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W019|645|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] actual bit length ** differs from formal bit length *** for port '**' (VERI-1330) (ip/DdrCtrl\DdrCtrl.sv:4817)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W020|646|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] input port '**' is not connected on this instance (VDB-1013) (ip/DdrCtrl\DdrCtrl.sv:4817)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W021|647|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] expression size ** truncated to fit in target size ** (VERI-1209) (ip/DdrCtrl\DdrCtrl.sv:1460)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W022|648|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] net '**' does not have a driver (VDB-1002) (ip/DdrCtrl\DdrCtrl.sv:1460)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W023|649|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] net '**' does not have a driver (VDB-1002) (ip/DdrCtrl\DdrCtrl.sv:590)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W024|650|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] input port '**' is not connected on this instance (VDB-1013) (ip/DdrCtrl\DdrCtrl.sv:590)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W025|651|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] input port '**' is not connected on this instance (VDB-1013) (ip/DdrCtrl\DdrCtrl.sv:2496)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W026|652|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] input port 'wr_data[127]' is not connected on this instance (VDB-1013) (ip/DdrCtrl\DdrCtrl.sv:117)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W027|653|EFX-0011|需要实物验证|[EFX-0011 VERI-WARNING] actual bit length 4 differs from formal bit length 8 for port 'axi_aid' (VERI-1330) (example_top.v:565)<br>4/8位AXI ID适配；当前发送ID固定0，但多事务/响应归属需验证|
|W028|654|EFX-0011|需要实物验证|[EFX-0011 VERI-WARNING] actual bit length 4 differs from formal bit length 8 for port 'axi_wid' (VERI-1330) (example_top.v:572)<br>4/8位AXI ID适配；当前发送ID固定0，但多事务/响应归属需验证|
|W029|655|EFX-0011|需要实物验证|[EFX-0011 VERI-WARNING] actual bit length 4 differs from formal bit length 8 for port 'axi_bid' (VERI-1330) (example_top.v:581)<br>响应ID窄化；不得扩展为多ID设计而不复核|
|W030|656|EFX-0011|需要实物验证|[EFX-0011 VERI-WARNING] actual bit length 4 differs from formal bit length 8 for port 'axi_rid' (VERI-1330) (example_top.v:587)<br>响应ID窄化；不得扩展为多ID设计而不复核|
|W031|657|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 2 truncated to fit in target size 1 (VERI-1209) (src\axi\AXI4_AWARMux.v:90)<br>1位r_reqtype加1实现轮换，按模2截断|
|W032|658|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 3 truncated to fit in target size 2 (VERI-1209) (example_top.v:745)<br>同步移位寄存器保留低2位；不能据此签收CDC|
|W033|659|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 5 truncated to fit in target size 4 (VERI-1209) (example_top.v:746)<br>同步移位寄存器保留低4位；不能据此签收CDC|
|W034|660|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] expression size 8 truncated to fit in target size 7 (VERI-1209) (src\PWMLite.v:22)<br>DSI PWM宽度，当前AR0135/HDMI链路不消费该外设|
|W035|661|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 64 differs from formal bit length 8 for port 'image_out_data' (VERI-1330) (example_top.v:898)<br>C_W_WIDTH=8，crop输出连接宽64但写FIFO只消费低8位|
|W036|662|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 32 truncated to fit in target size 16 (VERI-1209) (src\axi\axi4_ctrl.v:91)<br>axi_wstrb常量全1，128位总线只需16位字节使能|
|W037|663|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 3 truncated to fit in target size 2 (VERI-1209) (src\axi\axi4_ctrl.v:113)<br>4帧索引2位，模4递增|
|W038|664|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 3 truncated to fit in target size 2 (VERI-1209) (src\axi\axi4_ctrl.v:114)<br>4帧索引2位，模4递增/避开读帧|
|W039|665|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 3 truncated to fit in target size 2 (VERI-1209) (src\axi\axi4_ctrl.v:196)<br>4帧索引2位，模4递增|
|W040|666|EFX-0011|需要实物验证|[EFX-0011 VERI-WARNING] expression size 2 truncated to fit in target size 1 (VERI-1209) (src\axi\axi4_ctrl.v:238)<br>AXI写状态/突发计数截断；结合背压与连续帧实际验证|
|W041|667|EFX-0011|需要实物验证|[EFX-0011 VERI-WARNING] expression size 23 truncated to fit in target size 22 (VERI-1209) (src\axi\axi4_ctrl.v:257)<br>22位帧内写地址按模2^22回绕；需证实帧长/地址边界，不扩大容量证明|
|W042|668|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] port 'a_wr_rst_i' remains unconnected for this instance (VERI-1927) (ip/W0_FIFO_8\W0_FIFO_8.sv:116)<br>W0: BYPASS_RESET_SYNC=0；有效分支从a_rst_i同步，a_wr_rst_i仅用于关闭的旁路分支|
|W043|669|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 32 truncated to fit in target size 14 (VERI-1209) (ip/W0_FIFO_8\W0_FIFO_8.sv:1251)<br>W0幂次FIFO计数算术按目标计数位数取模，非数据总线截断|
|W044|670|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 32 truncated to fit in target size 10 (VERI-1209) (ip/W0_FIFO_8\W0_FIFO_8.sv:1252)<br>W0幂次FIFO计数算术按目标计数位数取模，非数据总线截断|
|W045|671|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] input port 'a_wr_rst_i' is not connected on this instance (VDB-1013) (ip/W0_FIFO_8\W0_FIFO_8.sv:95)<br>与668同一未启用复位旁路端口，预/后综合重复|
|W046|672|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] port 'a_wr_rst_i' remains unconnected for this instance (VERI-1927) (ip/R0_FIFO_8\R0_FIFO_8.v:109)<br>R0: BYPASS_RESET_SYNC=0；有效复位由a_rst_i同步|
|W047|673|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 32 truncated to fit in target size 10 (VERI-1209) (ip/R0_FIFO_8\R0_FIFO_8.v:1270)<br>R0计数表达式截断；本设计不连接count输出，实际消费empty/prog_full|
|W048|674|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 32 truncated to fit in target size 14 (VERI-1209) (ip/R0_FIFO_8\R0_FIFO_8.v:1271)<br>R0计数表达式截断；本设计不连接count输出，实际消费empty/prog_full|
|W049|675|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 9 differs from formal bit length 10 for port 'wr_datacount_o' (VERI-1330) (ip/R0_FIFO_8\R0_FIFO_8.v:104)<br>R0 wrapper计数宽度少1位，但当前axi4_ctrl不连接wr_datacount_o；未来使用必须修正|
|W050|676|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 13 differs from formal bit length 14 for port 'rd_datacount_o' (VERI-1330) (ip/R0_FIFO_8\R0_FIFO_8.v:107)<br>R0 wrapper计数宽度少1位，但当前axi4_ctrl不连接rd_datacount_o；未来使用必须修正|
|W051|677|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] input port 'a_wr_rst_i' is not connected on this instance (VDB-1013) (ip/R0_FIFO_8\R0_FIFO_8.v:89)<br>与672同一关闭的旁路分支端口|
|W052|678|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 17 truncated to fit in target size 16 (VERI-1209) (src\axi\axi4_ctrl.v:449)<br>16级复位忙移位寄存器保留低16位；复位跨域风险另列|
|W053|679|EFX-0011|需要实物验证|[EFX-0011 VERI-WARNING] expression size 23 truncated to fit in target size 22 (VERI-1209) (src\axi\axi4_ctrl.v:559)<br>22位帧内读地址回绕；需要帧长、缓冲区和背压验证|
|W054|680|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 32 differs from formal bit length 4 for port 'axi_bid' (VERI-1330) (example_top.v:968)<br>常量0的位宽告警；不代表响应握手已经被验证|
|W055|681|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 32 differs from formal bit length 2 for port 'axi_bresp' (VERI-1330) (example_top.v:969)<br>常量0的位宽告警；BRESP硬接0的错误可见性另列|
|W056|682|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 32 differs from formal bit length 1 for port 'axi_bvalid' (VERI-1330) (example_top.v:970)<br>常量1的位宽告警；BVALID硬接1的握手假设另列|
|W057|683|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 32 differs from formal bit length 2 for port 'axi_rresp' (VERI-1330) (example_top.v:980)<br>常量0的位宽告警；RRESP硬接0的错误可见性另列|
|W058|684|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 64 differs from formal bit length 8 for port 'wframe_data' (VERI-1330) (example_top.v:988)<br>8位灰度写流取64位crop连接的低8位|
|W059|685|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 16 differs from formal bit length 8 for port 'rframe_data' (VERI-1330) (example_top.v:993)<br>读流8位接16位lcd_data，但HDMI只取lcd_rgb低24位，来自lcd_data低8位；高半像素不用于HDMI|
|W060|686|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 8 differs from formal bit length 32 for port 'tp_o' (VERI-1330) (example_top.v:995)<br>tp_o诊断32位，仅低4位有定义并被LED[3:0]消费；不是相机数据截断|
|W061|687|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 8 truncated to fit in target size 4 (VERI-1209) (example_top.v:997)<br>LED仅使用tp_o低4位，其他诊断位未消费|
|W062|688|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] expression size 14 truncated to fit in target size 12 (VERI-1209) (src\lcd_driver.v:145)<br>hcnt14位转12位坐标；720p总行1650/有效1280均小于4096，坐标未消费|
|W063|689|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 32 differs from formal bit length 4 for port 'data_island_data' (VERI-1330) (src\hdmi_ip\rgb2dvi.v:50)<br>HDMI常量0/模式0或1，窄化不改变当前有效值；不代表视频协议全部验证|
|W064|690|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 4 differs from formal bit length 3 for port 'mode' (VERI-1330) (src\hdmi_ip\rgb2dvi.v:52)<br>HDMI常量0/模式0或1，窄化不改变当前有效值；不代表视频协议全部验证|
|W065|691|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 32 differs from formal bit length 4 for port 'data_island_data' (VERI-1330) (src\hdmi_ip\rgb2dvi.v:58)<br>HDMI常量0/模式0或1，窄化不改变当前有效值；不代表视频协议全部验证|
|W066|692|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 4 differs from formal bit length 3 for port 'mode' (VERI-1330) (src\hdmi_ip\rgb2dvi.v:60)<br>HDMI常量0/模式0或1，窄化不改变当前有效值；不代表视频协议全部验证|
|W067|693|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 32 differs from formal bit length 4 for port 'data_island_data' (VERI-1330) (src\hdmi_ip\rgb2dvi.v:66)<br>HDMI常量0/模式0或1，窄化不改变当前有效值；不代表视频协议全部验证|
|W068|694|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 4 differs from formal bit length 3 for port 'mode' (VERI-1330) (src\hdmi_ip\rgb2dvi.v:68)<br>HDMI常量0/模式0或1，窄化不改变当前有效值；不代表视频协议全部验证|
|W069|695|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] actual bit length 32 differs from formal bit length 1 for port 'oe_i' (VERI-1330) (example_top.v:1051)<br>oe_i常量1，截断后仍为1|
|W070|696|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] net 'w_dev_index_o[7]' does not have a driver (VDB-1002) (example_top.v:414)<br>厂商多接口模板遗留未驱动信号；当前AR0135到DDR到HDMI不消费对应外设|
|W071|697|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] net 'w_dev_cmd_o[7]' does not have a driver (VDB-1002) (example_top.v:415)<br>厂商多接口模板遗留未驱动信号；当前AR0135到DDR到HDMI不消费对应外设|
|W072|698|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] net 'w_dev_wdata_o[31]' does not have a driver (VDB-1002) (example_top.v:416)<br>厂商多接口模板遗留未驱动信号；当前AR0135到DDR到HDMI不消费对应外设|
|W073|699|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] net 'w_dev_wvalid_o' does not have a driver (VDB-1002) (example_top.v:417)<br>厂商多接口模板遗留未驱动信号；当前AR0135到DDR到HDMI不消费对应外设|
|W074|700|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] net 'w_spi_ssn_o' does not have a driver (VDB-1002) (example_top.v:421)<br>厂商多接口模板遗留未驱动信号；当前AR0135到DDR到HDMI不消费对应外设|
|W075|701|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] net 'w_spi_data_o[3]' does not have a driver (VDB-1002) (example_top.v:422)<br>厂商多接口模板遗留未驱动信号；当前AR0135到DDR到HDMI不消费对应外设|
|W076|702|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] net 'w_lcd_b_o[7]' does not have a driver (VDB-1002) (example_top.v:439)<br>厂商多接口模板遗留未驱动信号；当前AR0135到DDR到HDMI不消费对应外设|
|W077|703|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] input port 'SerialClk' is not connected on this instance (VDB-1013) (example_top.v:1044)<br>ENABLE_OSERDES=0，SerialClk未接；实际原生LVDS使用PLL pixel_10x|
|W078|704|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_ctl0_o' wire 'csi_ctl0_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W079|705|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_ctl1_o' wire 'csi_ctl1_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W080|706|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxc_hs_en_o' wire 'csi_rxc_hs_en_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W081|707|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxc_hs_term_en_o' wire 'csi_rxc_hs_term_en_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W082|708|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxd0_rst_o' wire 'csi_rxd0_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W083|709|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxd0_hs_en_o' wire 'csi_rxd0_hs_en_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W084|710|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxd0_hs_term_en_o' wire 'csi_rxd0_hs_term_en_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W085|711|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxd1_rst_o' wire 'csi_rxd1_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W086|712|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxd1_hs_en_o' wire 'csi_rxd1_hs_en_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W087|713|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxd1_hs_term_en_o' wire 'csi_rxd1_hs_term_en_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W088|714|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxd2_rst_o' wire 'csi_rxd2_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W089|715|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxd2_hs_en_o' wire 'csi_rxd2_hs_en_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W090|716|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxd2_hs_term_en_o' wire 'csi_rxd2_hs_term_en_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W091|717|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxd3_rst_o' wire 'csi_rxd3_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W092|718|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxd3_hs_en_o' wire 'csi_rxd3_hs_en_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W093|719|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'csi_rxd3_hs_term_en_o' wire 'csi_rxd3_hs_term_en_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W094|720|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_rst_o' wire 'dsi_txc_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W095|721|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_lp_p_oe' wire 'dsi_txc_lp_p_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W096|722|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_lp_p_o' wire 'dsi_txc_lp_p_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W097|723|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_lp_n_oe' wire 'dsi_txc_lp_n_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W098|724|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_lp_n_o' wire 'dsi_txc_lp_n_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W099|725|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_hs_oe' wire 'dsi_txc_hs_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W100|726|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_hs_o[7]' wire 'dsi_txc_hs_o[7]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W101|727|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_hs_o[6]' wire 'dsi_txc_hs_o[6]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W102|728|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_hs_o[5]' wire 'dsi_txc_hs_o[5]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W103|729|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_hs_o[4]' wire 'dsi_txc_hs_o[4]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W104|730|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_hs_o[3]' wire 'dsi_txc_hs_o[3]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W105|731|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_hs_o[2]' wire 'dsi_txc_hs_o[2]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W106|732|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_hs_o[1]' wire 'dsi_txc_hs_o[1]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W107|733|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txc_hs_o[0]' wire 'dsi_txc_hs_o[0]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W108|734|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_rst_o' wire 'dsi_txd0_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W109|735|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_hs_oe' wire 'dsi_txd0_hs_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W110|736|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_hs_o[7]' wire 'dsi_txd0_hs_o[7]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W111|737|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_hs_o[6]' wire 'dsi_txd0_hs_o[6]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W112|738|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_hs_o[5]' wire 'dsi_txd0_hs_o[5]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W113|739|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_hs_o[4]' wire 'dsi_txd0_hs_o[4]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W114|740|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_hs_o[3]' wire 'dsi_txd0_hs_o[3]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W115|741|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_hs_o[2]' wire 'dsi_txd0_hs_o[2]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W116|742|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_hs_o[1]' wire 'dsi_txd0_hs_o[1]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W117|743|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_hs_o[0]' wire 'dsi_txd0_hs_o[0]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W118|744|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_lp_p_oe' wire 'dsi_txd0_lp_p_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W119|745|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_lp_p_o' wire 'dsi_txd0_lp_p_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W120|746|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_lp_n_oe' wire 'dsi_txd0_lp_n_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W121|747|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd0_lp_n_o' wire 'dsi_txd0_lp_n_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W122|748|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_rst_o' wire 'dsi_txd1_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W123|749|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_lp_p_oe' wire 'dsi_txd1_lp_p_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W124|750|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_lp_p_o' wire 'dsi_txd1_lp_p_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W125|751|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_lp_n_oe' wire 'dsi_txd1_lp_n_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W126|752|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_lp_n_o' wire 'dsi_txd1_lp_n_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W127|753|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_hs_oe' wire 'dsi_txd1_hs_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W128|754|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_hs_o[7]' wire 'dsi_txd1_hs_o[7]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W129|755|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_hs_o[6]' wire 'dsi_txd1_hs_o[6]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W130|756|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_hs_o[5]' wire 'dsi_txd1_hs_o[5]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W131|757|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_hs_o[4]' wire 'dsi_txd1_hs_o[4]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W132|758|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_hs_o[3]' wire 'dsi_txd1_hs_o[3]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W133|759|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_hs_o[2]' wire 'dsi_txd1_hs_o[2]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W134|760|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_hs_o[1]' wire 'dsi_txd1_hs_o[1]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W135|761|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd1_hs_o[0]' wire 'dsi_txd1_hs_o[0]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W136|762|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_rst_o' wire 'dsi_txd2_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W137|763|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_lp_p_oe' wire 'dsi_txd2_lp_p_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W138|764|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_lp_p_o' wire 'dsi_txd2_lp_p_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W139|765|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_lp_n_oe' wire 'dsi_txd2_lp_n_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W140|766|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_lp_n_o' wire 'dsi_txd2_lp_n_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W141|767|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_hs_oe' wire 'dsi_txd2_hs_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W142|768|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_hs_o[7]' wire 'dsi_txd2_hs_o[7]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W143|769|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_hs_o[6]' wire 'dsi_txd2_hs_o[6]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W144|770|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_hs_o[5]' wire 'dsi_txd2_hs_o[5]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W145|771|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_hs_o[4]' wire 'dsi_txd2_hs_o[4]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W146|772|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_hs_o[3]' wire 'dsi_txd2_hs_o[3]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W147|773|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_hs_o[2]' wire 'dsi_txd2_hs_o[2]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W148|774|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_hs_o[1]' wire 'dsi_txd2_hs_o[1]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W149|775|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd2_hs_o[0]' wire 'dsi_txd2_hs_o[0]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W150|776|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_rst_o' wire 'dsi_txd3_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W151|777|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_lp_p_oe' wire 'dsi_txd3_lp_p_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W152|778|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_lp_p_o' wire 'dsi_txd3_lp_p_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W153|779|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_lp_n_oe' wire 'dsi_txd3_lp_n_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W154|780|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_lp_n_o' wire 'dsi_txd3_lp_n_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W155|781|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_hs_oe' wire 'dsi_txd3_hs_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W156|782|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_hs_o[7]' wire 'dsi_txd3_hs_o[7]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W157|783|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_hs_o[6]' wire 'dsi_txd3_hs_o[6]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W158|784|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_hs_o[5]' wire 'dsi_txd3_hs_o[5]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W159|785|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_hs_o[4]' wire 'dsi_txd3_hs_o[4]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W160|786|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_hs_o[3]' wire 'dsi_txd3_hs_o[3]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W161|787|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_hs_o[2]' wire 'dsi_txd3_hs_o[2]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W162|788|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_hs_o[1]' wire 'dsi_txd3_hs_o[1]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W163|789|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'dsi_txd3_hs_o[0]' wire 'dsi_txd3_hs_o[0]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W164|790|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'uart_tx_o' wire 'uart_tx_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W165|791|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'led_o[4]' wire 'led_o[4]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W166|792|EFX-0256|必须修复|[EFX-0256 WARNING] The primary output port 'cmos_ctl2' wire 'cmos_ctl2' is not driven.<br>必须修复控制定义：RTL输出无驱动，最终网表固定0；TRIGGER低、OE_BAR低为使能，不满足专用安全启动要求|
|W167|793|EFX-0256|必须修复|[EFX-0256 WARNING] The primary output port 'cmos_ctl3' wire 'cmos_ctl3' is not driven.<br>必须修复控制定义：RTL输出无驱动，最终网表固定0；TRIGGER低、OE_BAR低为使能，不满足专用安全启动要求|
|W168|794|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txc_oe' wire 'lvds_txc_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W169|795|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txc_o[6]' wire 'lvds_txc_o[6]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W170|796|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txc_o[5]' wire 'lvds_txc_o[5]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W171|797|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txc_o[4]' wire 'lvds_txc_o[4]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W172|798|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txc_o[3]' wire 'lvds_txc_o[3]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W173|799|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txc_o[2]' wire 'lvds_txc_o[2]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W174|800|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txc_o[1]' wire 'lvds_txc_o[1]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W175|801|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txc_o[0]' wire 'lvds_txc_o[0]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W176|802|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txc_rst_o' wire 'lvds_txc_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W177|803|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd0_oe' wire 'lvds_txd0_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W178|804|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd0_o[6]' wire 'lvds_txd0_o[6]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W179|805|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd0_o[5]' wire 'lvds_txd0_o[5]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W180|806|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd0_o[4]' wire 'lvds_txd0_o[4]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W181|807|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd0_o[3]' wire 'lvds_txd0_o[3]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W182|808|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd0_o[2]' wire 'lvds_txd0_o[2]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W183|809|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd0_o[1]' wire 'lvds_txd0_o[1]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W184|810|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd0_o[0]' wire 'lvds_txd0_o[0]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W185|811|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd0_rst_o' wire 'lvds_txd0_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W186|812|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd1_oe' wire 'lvds_txd1_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W187|813|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd1_o[6]' wire 'lvds_txd1_o[6]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W188|814|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd1_o[5]' wire 'lvds_txd1_o[5]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W189|815|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd1_o[4]' wire 'lvds_txd1_o[4]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W190|816|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd1_o[3]' wire 'lvds_txd1_o[3]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W191|817|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd1_o[2]' wire 'lvds_txd1_o[2]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W192|818|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd1_o[1]' wire 'lvds_txd1_o[1]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W193|819|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd1_o[0]' wire 'lvds_txd1_o[0]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W194|820|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd1_rst_o' wire 'lvds_txd1_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W195|821|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd2_oe' wire 'lvds_txd2_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W196|822|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd2_o[6]' wire 'lvds_txd2_o[6]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W197|823|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd2_o[5]' wire 'lvds_txd2_o[5]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W198|824|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd2_o[4]' wire 'lvds_txd2_o[4]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W199|825|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd2_o[3]' wire 'lvds_txd2_o[3]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W200|826|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd2_o[2]' wire 'lvds_txd2_o[2]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W201|827|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd2_o[1]' wire 'lvds_txd2_o[1]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W202|828|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd2_o[0]' wire 'lvds_txd2_o[0]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W203|829|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd2_rst_o' wire 'lvds_txd2_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W204|830|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd3_oe' wire 'lvds_txd3_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W205|831|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd3_o[6]' wire 'lvds_txd3_o[6]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W206|832|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd3_o[5]' wire 'lvds_txd3_o[5]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W207|833|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd3_o[4]' wire 'lvds_txd3_o[4]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W208|834|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd3_o[3]' wire 'lvds_txd3_o[3]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W209|835|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd3_o[2]' wire 'lvds_txd3_o[2]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W210|836|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd3_o[1]' wire 'lvds_txd3_o[1]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W211|837|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd3_o[0]' wire 'lvds_txd3_o[0]' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W212|838|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lvds_txd3_rst_o' wire 'lvds_txd3_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W213|839|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lcd_tp_sda_o' wire 'lcd_tp_sda_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W214|840|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lcd_tp_sda_oe' wire 'lcd_tp_sda_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W215|841|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lcd_tp_scl_o' wire 'lcd_tp_scl_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W216|842|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lcd_tp_scl_oe' wire 'lcd_tp_scl_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W217|843|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lcd_tp_int_o' wire 'lcd_tp_int_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W218|844|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lcd_tp_int_oe' wire 'lcd_tp_int_oe' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W219|845|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lcd_tp_rst_o' wire 'lcd_tp_rst_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W220|846|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lcd_pwm_o' wire 'lcd_pwm_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W221|847|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lcd_blen_o' wire 'lcd_blen_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W222|848|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lcd_vs_o' wire 'lcd_vs_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W223|849|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lcd_hs_o' wire 'lcd_hs_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W224|850|EFX-0256|与当前设计无关|[EFX-0256 WARNING] The primary output port 'lcd_de_o' wire 'lcd_de_o' is not driven.<br>未启用的DSI/LVDS/CSI/LCD/UART或未消费LED输出；仅在这些外设保持不接入且不依赖其输出时与当前链路无关，不能跨用途豁免|
|W225|851|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Q7_Out[4][7]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W226|852|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Q7_Out[4][6]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W227|853|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Q7_Out[4][5]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W228|854|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Q7_Out[4][4]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W229|855|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Q7_Out[4][3]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W230|856|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Q7_Out[4][2]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W231|857|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Q7_Out[4][1]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W232|858|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Q7_Out[4][0]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W233|859|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Out[7]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W234|860|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Out[6]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W235|861|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Out[5]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W236|862|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Out[4]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W237|863|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Out[3]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W238|864|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Out[2]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W239|865|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Out[1]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W240|866|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Out[0]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W241|867|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Q7_Out[4][31]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W242|868|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Q7_Out[4][30]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W243|869|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Q7_Out[4][29]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W244|870|EFX-0200|需要实物验证|[EFX-0200 WARNING] Removing redundant signal : Shift_Q7_Out[4][28]. (ip/DdrCtrl\DdrCtrl.sv:2611)<br>DDR校准移位信号冗余删除：不是已证实故障，也未证明为无害；需当前IP校准说明和I3实测lane/重启/压力证据|
|W245|871|EFX-0201|必须修复|[EFX-0201 WARNING] Re-wiring to GND non-driven net 'u_efx_fifo_top.a_rst_i'. (ip/DdrCtrl\DdrCtrl.sv:4817)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W246|872|EFX-0201|必须修复|[EFX-0201 WARNING] Re-wiring to GND non-driven net 'u_efx_fifo_top.clk_i'. (ip/DdrCtrl\DdrCtrl.sv:4817)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W247|873|EFX-0201|必须修复|[EFX-0201 WARNING] Re-wiring to GND non-driven net 'r_rd_fifo_wr_en_p[31]'. (ip/DdrCtrl\DdrCtrl.sv:1460)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W248|874|EFX-0201|必须修复|[EFX-0201 WARNING] Re-wiring to GND non-driven net 'r_rd_fifo_wr_en_p[30]'. (ip/DdrCtrl\DdrCtrl.sv:1460)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W249|875|EFX-0201|必须修复|[EFX-0201 WARNING] Re-wiring to GND non-driven net 'r_rd_fifo_wr_en_p[29]'. (ip/DdrCtrl\DdrCtrl.sv:1460)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W250|876|EFX-0201|必须修复|[EFX-0201 WARNING] Re-wiring to GND non-driven net 'r_rd_fifo_wr_en_p[28]'. (ip/DdrCtrl\DdrCtrl.sv:1460)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W251|877|EFX-0201|必须修复|[EFX-0201 WARNING] Re-wiring to GND non-driven net 'r_rd_fifo_wr_en_p[27]'. (ip/DdrCtrl\DdrCtrl.sv:1460)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W252|878|EFX-0201|必须修复|[EFX-0201 WARNING] Re-wiring to GND non-driven net 'r_rd_fifo_wr_en_p[26]'. (ip/DdrCtrl\DdrCtrl.sv:1460)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W253|879|EFX-0201|必须修复|[EFX-0201 WARNING] Re-wiring to GND non-driven net 'r_rd_fifo_wr_en_p[25]'. (ip/DdrCtrl\DdrCtrl.sv:1460)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W254|880|EFX-0201|必须修复|[EFX-0201 WARNING] Re-wiring to GND non-driven net 'r_rd_fifo_wr_en_p[24]'. (ip/DdrCtrl\DdrCtrl.sv:1460)<br>必须澄清：当前DDR v5.14加密内部未连接/位宽/无驱动/接地告警，不能由旧厂商bit跑通推定新IP已安全；需厂商解释有效分支或修复|
|W255|881|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] Input/inout port clk_24m is unconnected and will be removed. (VDB-8003) (example_top.v:11)<br>clk_24m在接口层直达PLL，RTL端口移除不等于板卡输入时钟消失|
|W256|882|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port clk_25m is unconnected and will be removed. (VDB-8003) (example_top.v:12)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W257|883|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] Input/inout port clk_pixel_2x is unconnected and will be removed. (VDB-8003) (example_top.v:21)<br>pixel_2x由接口/PLL使用，RTL未消费；核对接口时钟而非新增虚假RTL负载|
|W258|884|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] Input/inout port clk_pixel_10x is unconnected and will be removed. (VDB-8003) (example_top.v:22)<br>pixel_10x直达原生LVDS串行器，RTL端口删除不等于串行时钟缺失|
|W259|885|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port dsi_refclk_i is unconnected and will be removed. (VDB-8003) (example_top.v:30)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W260|886|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port dsi_byteclk_i is unconnected and will be removed. (VDB-8003) (example_top.v:31)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W261|887|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port dsi_serclk_i is unconnected and will be removed. (VDB-8003) (example_top.v:32)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W262|888|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port dsi_txcclk_i is unconnected and will be removed. (VDB-8003) (example_top.v:33)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W263|889|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port clk_lvds_1x is unconnected and will be removed. (VDB-8003) (example_top.v:60)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W264|890|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port clk_lvds_7x is unconnected and will be removed. (VDB-8003) (example_top.v:61)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W265|891|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] Input/inout port clk_27m is unconnected and will be removed. (VDB-8003) (example_top.v:62)<br>clk_27m为历史命名，实际16MHz；接口clkout驱动XCLK|
|W266|892|EFX-0011|已知IP噪声|[EFX-0011 VERI-WARNING] Input/inout port clk_54m is unconnected and will be removed. (VDB-8003) (example_top.v:63)<br>clk_54m为历史命名，实际32MHz，未被业务RTL消费|
|W267|893|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] Input/inout port i_dqs_n_hi[1] is unconnected and will be removed. (VDB-8003) (example_top.v:97)<br>必须澄清：DQS负相位hi[1]在top连接控制器却被移除，不能仅因加密IP就豁免|
|W268|894|EFX-0011|必须修复|[EFX-0011 VERI-WARNING] Input/inout port i_dqs_n_lo[1] is unconnected and will be removed. (VDB-8003) (example_top.v:98)<br>必须澄清：DQS负相位lo[1]在top连接控制器却被移除，需IP采样结构依据|
|W269|895|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_ctl0_i is unconnected and will be removed. (VDB-8003) (example_top.v:121)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W270|896|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_ctl1_i is unconnected and will be removed. (VDB-8003) (example_top.v:125)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W271|897|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_scl_i is unconnected and will be removed. (VDB-8003) (example_top.v:129)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W272|898|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_sda_i is unconnected and will be removed. (VDB-8003) (example_top.v:133)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W273|899|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxc_lp_p_i is unconnected and will be removed. (VDB-8003) (example_top.v:136)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W274|900|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxc_lp_n_i is unconnected and will be removed. (VDB-8003) (example_top.v:137)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W275|901|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxc_i is unconnected and will be removed. (VDB-8003) (example_top.v:140)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W276|902|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxd0_lp_p_i is unconnected and will be removed. (VDB-8003) (example_top.v:147)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W277|903|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxd0_lp_n_i is unconnected and will be removed. (VDB-8003) (example_top.v:148)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W278|904|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxd0_hs_i[7] is unconnected and will be removed. (VDB-8003) (example_top.v:149)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W279|905|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxd1_lp_n_i is unconnected and will be removed. (VDB-8003) (example_top.v:156)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W280|906|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxd1_lp_p_i is unconnected and will be removed. (VDB-8003) (example_top.v:157)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W281|907|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxd1_hs_i[7] is unconnected and will be removed. (VDB-8003) (example_top.v:158)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W282|908|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxd2_lp_p_i is unconnected and will be removed. (VDB-8003) (example_top.v:165)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W283|909|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxd2_lp_n_i is unconnected and will be removed. (VDB-8003) (example_top.v:166)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W284|910|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxd2_hs_i[7] is unconnected and will be removed. (VDB-8003) (example_top.v:167)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W285|911|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxd3_lp_p_i is unconnected and will be removed. (VDB-8003) (example_top.v:174)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W286|912|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxd3_lp_n_i is unconnected and will be removed. (VDB-8003) (example_top.v:175)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W287|913|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port csi_rxd3_hs_i[7] is unconnected and will be removed. (VDB-8003) (example_top.v:176)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W288|914|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port dsi_txd0_lp_p_i is unconnected and will be removed. (VDB-8003) (example_top.v:235)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W289|915|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port dsi_txd0_lp_n_i is unconnected and will be removed. (VDB-8003) (example_top.v:236)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W290|916|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port dsi_txd1_lp_p_i is unconnected and will be removed. (VDB-8003) (example_top.v:237)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W291|917|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port dsi_txd1_lp_n_i is unconnected and will be removed. (VDB-8003) (example_top.v:238)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W292|918|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port dsi_txd2_lp_p_i is unconnected and will be removed. (VDB-8003) (example_top.v:239)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W293|919|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port dsi_txd2_lp_n_i is unconnected and will be removed. (VDB-8003) (example_top.v:240)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W294|920|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port dsi_txd3_lp_p_i is unconnected and will be removed. (VDB-8003) (example_top.v:241)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W295|921|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port dsi_txd3_lp_n_i is unconnected and will be removed. (VDB-8003) (example_top.v:242)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W296|922|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port uart_rx_i is unconnected and will be removed. (VDB-8003) (example_top.v:247)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W297|923|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port cmos_ctl1 is unconnected and will be removed. (VDB-8003) (example_top.v:266)<br>模块FLASH strobe输入未使用；它不是SPI Flash，也不是相机RESET|
|W298|924|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port lcd_tp_sda_i is unconnected and will be removed. (VDB-8003) (example_top.v:316)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W299|925|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port lcd_tp_scl_i is unconnected and will be removed. (VDB-8003) (example_top.v:320)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W300|926|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port lcd_tp_int_i is unconnected and will be removed. (VDB-8003) (example_top.v:324)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W301|927|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port lcd_b7_0_i[7] is unconnected and will be removed. (VDB-8003) (example_top.v:344)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W302|928|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port lcd_g7_0_i[7] is unconnected and will be removed. (VDB-8003) (example_top.v:345)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
|W303|929|EFX-0011|与当前设计无关|[EFX-0011 VERI-WARNING] Input/inout port lcd_r7_0_i[7] is unconnected and will be removed. (VDB-8003) (example_top.v:346)<br>当前未启用的25MHz/DSI/LVDS/CSI/UART/触摸或LCD输入端口被优化；当前相机数据PCLK/HREF/VSYNC未被删除|
