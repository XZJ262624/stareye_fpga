# 实际启用DDR路径与证据

本轮基线为 `4e0496e8a36f53dcfffa9e9564ffbf0f780a55ba`，工程 `efinity/m5a_streaming_canny_i3/Ti60_Demo.xml`。以下行号均以仓库根为基准，源文件不修改；机器可读行号、命中片段及SHA见 ADDRESS_CHECK_RESULTS.json。

|问题|实际证据|结论|
|---|---|---|
|启用AXI管理器|工程XML:28列 `src/axi/axi4_ctrl.v`；example_top.v:956实例化|不是 `src/axi4_ctrl.v`。后者同名历史文件不在启用清单|
|旧native控制器|XML:10列src/ddr_rw_ctrl.v，但example_top无其实例；该旧文件:约160–205三缓冲索引、:343/364地址拼接|仅列源不等于进入网表；不能套三缓冲或native地址单位|
|地址单位|src/axi/axi4_ctrl.v:4–14数据128bit、STRB16B、ADDR_INC=128×16；:257/+C_ADDR_INC；:263/565拼帧索引和指针；top:630 asize=4、INCR=1|32-bit AXI byte address，每拍16B；不是16bit word或128bit beat地址|
|视频槽|axi4_ctrl.v:13 BUF_SIZE22，:109–144二位四帧索引，:263/565索引拼22位指针|槽0/1/2/3基址0/0x00400000/0x00800000/0x00C00000，stride=0x00400000，整体[0,0x01000000)保留|
|有效载荷|top:865 CSI_DATA_WIDTH8；:956 C_W_WIDTH8/C_R_WIDTH8，RD_END=1280×720|一像素一字节，16像素/拍；921600B=57600拍=450个2048B突发；未存RGB888|
|连续布局|axi4_ctrl.v:168/257写指针按突发增、:523读到RD_END、:559读指针增|每行逻辑1280B，无行stride空洞。128拍burst可跨图像行；视频结束恰好整burst|
|最大写址|axi4_ctrl.v:168写指针22位，正常帧EOF复位；写路径无921600B硬限|即使正常payload较小，不能把每4MiB槽尾当新空闲；错误超长流可能覆盖槽尾|
|用户端口|DdrCtrl.sv:90–114单A/W/B/R、AADDR32、ID8、DATA128、WSTRB16；top:471–512用ID4|一个modified AXI口，没有证据证明空闲第二主口；未来路由需明确8位IP ID与4位旧接口关系|
|AW/AR桥|top:606–627 AXI4_AWARMux；src/axi/AXI4_AWARMux.v:44–115|现有读/写命令round-robin，非多主仲裁；不能仅再OR一个valid|
|真实响应|top:580–602连接IP B，BREADY常1；:972–974旧master BID=0/BRESP=0/BVALID=1，:985 RRESP=0|旧EOF、最后W拍不是新快照提交栅栏。未来新DMA必须跟踪真实B/RRESP、ID、RLAST和全部未决事务|
|校准放行|top:513–523 r_ddr_unlock只跟cal_done；:596–597 cal_pass有线但不参与unlock|新增业务必须cal_done AND cal_pass AND PLL稳定；失败不得发布或复用未知DDR内容|
|存储几何|ip/DdrCtrl/settings.json:17–23 data_width1/freq384/col10/row15/bank3；ddr3_controller.vh:25–33 DRAM_WIDTH16、ROW15/COL10/BANK3、WFIFO128、BL8|配置容量2^(15+10+3)×2=536870912B。外部addr[15:0]并不证明16有效row bits|
|地址译码边界|DdrCtrl.sv:192起加密保护内核，可见wrapper不提供host→bank/row/column位分解|用户口宽32≠4GiB有效容量；29-bit物理容量≠已经证明[0,512MiB)无别名。校准/内部测试保留区无法从可见核完整排除|
|时钟|top:464 ui=clk_sys；peri.xml:567/575系统PLL与反馈，:589 DDR PLL参考96MHz；最终timing.rpt:34–39|UI96MHz，core192MHz，DDR384MHz，pixel74.4MHz；timing显示小数为周期舍入，非新实测频率|
|STA/资源|outflow/Ti60_Demo.place.rpt:21–31；timing.rpt:79/100等；历史M5A最终STA审计|9425/60800 XLR、105/256 RAM、0/160 DSP。M5A最终最差setup/hold +0.194/+0.026ns。无M5B新增综合/STA|

M2当前工程与其 `reports/m2_ar0135_ddr_hdmi_i3/final_build/source_snapshot` 的实际AXI管理器、AWAR桥、DdrCtrl settings及DdrCtrl.sv已逐字节对比，均与本轮M5A对应文件相同（8项），见JSON。这只是指定文件对比，不宣称当前M2全部再生成输入等于当年构建。M2的 DDR_IP_MIGRATION.md 亦明确512MiB组织与加密核地址映射未通过全容量读写验证；本轮独立源码判断与该边界一致。

`arbiter_count=4` 是IP内部调度参数，不是四个外部用户端口。工程启用清单、顶层实例及可见wrapper只有一个连接的用户端口。未发现可见生产客户端占用高于0x01000000的业务地址；此发现不能排除加密IP校准/测试区，也不能证明未使用区物理安全。

现有写FIFO为W0_FIFO_8异步8→128、深度2^13个8bit输入=8192B；settings中的PROG_EMPTY表示足一突发的门限，不能被当作剩余整帧余量。读FIFO R0_FIFO_8.v:73–86为128→8、深度512个128bit=8192B，prog_full=256拍=4096B，非half-empty读deadline保障。两FIFO原实现保留。本轮不外推overflow/underflow保护能阻止相机/HDMI像素丢失：源实时数据不可回压，HDMI亦不能等待。

候选新增地址[0x01000000,0x010E7000)与软件产生的四槽范围不重叠，含4KiB页对齐空洞与metadata。它是规划地址；**新增已验证安全字节数=0**。解除地址阻断需要从许可IP手册/供应商确认完整解码及校准保留区，或在以后独立授权验证环境覆盖候选边界和全部视频槽的地址唯一性、不同花纹、4KiB/2KiB/高位跳转与复位重校准，确认互不覆盖。不能未经证明先写入这些候选地址。

AXI 4KiB不得跨burst的限制由planner硬性拆分。物理每bank row有1024×16bit=2048B，但host位到bank/page映射未知，不能据此称每host2KiB就是物理页。跨行指图像逻辑跨行，与DDR page命中无直接等同；跨bank/row切换、读写转向和刷新损耗作为带宽未知因素。高于0x20000000至0x100000000全部禁止，可能被截断别名到低地址。
