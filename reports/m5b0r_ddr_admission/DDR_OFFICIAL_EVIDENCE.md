# DDR官方证据与未证部分
本轮只离线核查，实物新增安全DDR容量仍为0。

|证据|已确认|尚不能推出|
|`../../efinity/m2_ar0135_ddr_hdmi_i3/ip/DdrCtrl/settings.json`|v5.14，x16、row15/col10/bank3、384MHz、CL6；控制UI96MHz、core192MHz|物理高位译码与保留地址|
|本地 `E:/Efinity/2025.1/ipm/ip/efx_ddr3_soft_controller/ipm/doc/topics/hlp-ddr3-soft-controller.html`，UG-CORE-DDR3-CONTROLLER-v2.1|半速率DDR3控制器、校准和缓冲结构，几何参数范围|没有明确公开当前所有地址映射/校准保留区|
|M2 `ip/DdrCtrl/Testbench/memory_checker_axi.v`，WIDTH/ADDR_OFFSET/ASIZE|AADDR32、128bit拍、ASIZE4；ADDR_OFFSET=(ALEN+1)*(WIDTH/8)，地址按字节递增|不能单凭端口宽32证明512MiB全部可达|
|官方 `source_efinity/efx_ddr3_axi.v` 等加密源|统一A命令加W/B/R；atype=1写、0读|内部高位截断、row/column/bank排列、校准保留地址不可权威核实|
|已验收 `src/axi/axi4_ctrl.v`|C_BUFSIZE22、四个4MiB槽，仅分配前16MiB|不是控制器容量仅16MiB的证据|

物理Samsung K4B4G1646E-BYMA为用户已确认512MiB颗粒。候选[0x01000000,0x010E7000)按字节算术合法，但0x01000000是否实际安全需要实物别名/范围测试和厂商保留区证据。不能借软件映射一致性认证物理地址单位。
