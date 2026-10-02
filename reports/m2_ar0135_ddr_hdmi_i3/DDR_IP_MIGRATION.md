# DDR与FIFO迁移审查

## M2本轮实物确认（2026-10-02）

用户文字确认：AR0135相机PCB V5.0；核心板VF-Ti60F225 V1.5；底板VF-Ti60/125F225 V1.5；DDR丝印SEC 307 / K4B4G1646 / 46E BYMA，用户确认Samsung K4B4G1646E-BYMA，4Gbit、256M×16、512MiB。FPGA为Ti60F225I3，Efinity位于E:/Efinity/2025.1，实际版本2025.1.110.5.9。依据是用户实物文字确认，代理未独立检查实物。原理图MT41J128M16与实物不同，DDR参数按实物重新核查。

相机仍断开，旧Flash官方流水灯仍可能驱动共享R3/R4。V5.0针脚、朝向、供电、电平及冷启动隔离未经确认，禁止接入或上电相机。AR0135CS数据手册p17 Table12规定VIN/VOUT绝对最大VDD_IO+0.3V；旧2019模块图VDDIO=2.8V对应3.1V。若V5.0仍使用该供电且无转换，当前3.3V XCLK/SCL/主动SDA可能超过该上限；这是条件性资料风险，不是实物超压或损坏证据。必须确认V5.0电平转换后才能接线。

本轮授权M2完整离线迁移/编译，不授权Programmer、JTAG下载、SPI Active、Flash、摄像头连接、灰度化或Sobel。离线结果见[BUILD_REPORT](BUILD_REPORT.md)；不把编译等同DDR校准或相机直通验收。

## 官方DDR依据与参数换算

Samsung官方K4B4G1646E-BY Rev1.1数据手册：[官方PDF](https://image.semiconductor.samsung.com/resources/data-sheet/DS_K4B4G1646E_BY_M_Rev1_11-0.pdf)，表51 DDR3-1866(MA)及器件组织/电压表。官方网页检索获得原文，PDF下载不可达，未声称逐页渲染。

- x16，row15、col10、bank3（8Bank）、1rank；2^(15+10+3)×16bit=4Gbit=512MiB。旧row16错误，已改15。IP地址输出仍固定[15:0]，未改变顶层或管脚；加密内核A15动态值未独立证明，不能把端口宽度当作row16仍生效，实际容量/地址映射留待DDR读写测试。
- 192MHz core/384MHz DDR维持；tCK=2.6041667ns、768MT/s。CL5不满足MA降频CL5的tCK≥3ns要求；CL6/CWL5允许2.5–3.3ns。CL6×tCK=15.625ns，满足tAA13.91ns；新MR0随CL6生成。不是以“未升频”代替CAS审查。
- tRCD/tRP选择15ns（6CK=15.625ns），tRAS37.5ns（15CK=39.0625ns），tRC52.5ns，比MA13.91/13.91/34/47.91ns保守。
- 当前IP固定tRFC350ns（135CK=351.5625ns）、tXS360ns，相对4Gb器件260ns/tRFC+10ns更保守；不误当4Gb必须缩为260ns。tWR6CK=15.625ns，tCCD/tRTP/tWTR4CK=10.4167ns；tMRD4CK、tMOD12CK、ZQinit512CK、reset200us、CKE500us显式审查。
- tREFI7800ns适用常温刷新等级；高温需倍频刷新，当前未验实际温度。官方生成REF_INTERVAL=2995.2；加密内核实际取整/调度端到端间隔未证明，不能宣称刷新实测PASS。
- BY为DDR3L并支持1.5V运行；本工程DDR银行1.5V。1.5V模式VDD/VDDQ范围1.425–1.575V；实物电压未测。
- READ_ENABLE_PIPELINE明确7，为CL之外附加流水级，未接受新默认8。CL随tRL变6，保留额外7，是否在当前板延迟/校准窗口有效仍待DDR校准测试。
- qoff=1在官方generator/instruction_ram_halfrate.py映射MR1 bit12=0（输出使能），不是JEDEC bit12的直接数值。
- 新PLL_OUT_SEL=4来自官方默认且显式传递，生成宏5'd4；顶层原shift_sel=5'b00100保持，选OUT2/tac_clk。未通过硬件校准证明新IP整个动态移相行为。

## 逐项用户配置对照


### DdrCtrl

|字段|旧|新|处理|
|---|---|---|---|
|DDR3_DATA_RATE|`1`|`2`|已审查变化，说明见上下文|
|DDR3_MODE|`2`|`2`|保持|
|PLL_OUT_SEL|`未显式`|`4`|已审查变化，说明见上下文|
|READ_ENABLE_PIPELINE|`7`|`7`|保持|
|al|`0`|`0`|保持|
|arbiter_count|`4`|`4`|保持|
|arbiter_init|`1`|`1`|保持|
|asr|`1'b0`|`1'b0`|保持|
|bank|`3`|`3`|保持|
|burst_length|`8`|`8`|保持|
|cas_latency|`5`|`6`|已审查变化，说明见上下文|
|col|`未显式`|`10`|已审查变化，说明见上下文|
|data_width|`1'b1`|`1`|已审查变化，说明见上下文|
|dll_enable|`1'b1`|`1'b1`|保持|
|dll_reset|`1`|`1`|保持|
|dynamic_odt|`0`|`0`|保持|
|freq|`384`|`384`|保持|
|mpr|`1'b0`|`1'b0`|保持|
|mpr_rf|`0`|`0`|保持|
|output_drive_strength|`1'b0`|`1'b0`|保持|
|precharge_pd|`1'b1`|`1'b1`|保持|
|qoff|`1'b1`|`1'b1`|保持|
|rank|`1`|`派生/不再保存`|已审查变化，说明见上下文|
|read_burst_type|`1'b0`|`1'b0`|保持|
|row|`16`|`15`|已审查变化，说明见上下文|
|rtt|`3`|`3`|保持|
|simulation|`1'b0`|`派生/不再保存`|已审查变化，说明见上下文|
|srt|`1'b0`|`1'b0`|保持|
|tREFI|`7800`|`7800`|保持|
|tdqs|`1'b0`|`1'b0`|保持|
|write_leveling|`1'b0`|`1'b0`|保持|

### W0_FIFO_8

|字段|旧|新|处理|
|---|---|---|---|
|ASYM_WIDTH_RATIO|`8`|`8`|保持|
|BYPASS_RESET_SYNC|`0`|`0`|保持|
|DATA_WIDTH|`8`|`8`|保持|
|DEPTH_2|`13`|`13`|保持|
|ENDIANESS|`0`|`0`|保持|
|FAMILY|`"TRION"`|`派生/不再保存`|已审查变化，说明见上下文|
|MODE|`"FWFT"`|`"FWFT"`|保持|
|OPTIONAL_FLAGS|`1`|`1`|保持|
|OUTPUT_REG|`0`|`0`|保持|
|OVERFLOW_PROTECT|`未显式`|`1`|已审查变化，说明见上下文|
|PEA_INTERNAL|`127`|`127`|保持|
|PEN_INTERNAL|`128`|`128`|保持|
|PFN_INTERNAL|`127`|`127`|保持|
|PIPELINE_REG|`1`|`1`|保持|
|PROGRAMMABLE_EMPTY|`"STATIC_SINGLE"`|`"STATIC_SINGLE"`|保持|
|PROGRAMMABLE_FULL|`"NONE"`|`"NONE"`|保持|
|PROG_FULL_ASSERT|`128`|`128`|保持|
|RAM_STYLE|`未显式`|`"block_ram"`|已审查变化，说明见上下文|
|SYNC_CLK|`0`|`0`|保持|
|SYNC_STAGE|`3`|`3`|保持|
|UNDERFLOW_PROTECT|`未显式`|`1`|已审查变化，说明见上下文|

## FIFO兼容性边界

W0_FIFO_8从v5.0升级v8.0，实际生成HDL FAMILY="TITANIUM"；18个旧配置除FAMILY修正外按原值传递。8bit写入、128bit读出、8192写深度、双时钟、FWFT、3级指针同步、PIPELINE_REG=1、OUTPUT_REG=0、异步复位且保留内部reset同步。PEA127/PEN128，满阈值128且可编程满标志NONE，端序0。

新增RAM_STYLE="block_ram"与旧BRAM实现对应；OVERFLOW_PROTECT=1、UNDERFLOW_PROTECT=1与旧RTL wr_en_int=we & ~wr_full、rd_en_int受~rd_empty_int门控相符。旧FWFT自动预取亦受empty门控。新版本架构/综合器实现变化未做独立FIFO功能或形式等价仿真，不把配置对齐扩大成所有复位/满空并发边界等价证明。

其他IP和全部PLL保留。新IP使用.sv与.svh，通过官方projectdb更新工程源项；目录中旧.v/.vh是历史副本，不参与新DdrCtrl/W0_FIFO_8编译。所有实际输入由构建清单绑定。

## 参数语义和固定生成值补充

DDR3_DATA_RATE由1(800D)改2(800E)，对应384MHz下6-6-6而非原5-5-5；cas_latency6生成tRL6，CWL5生成tWL5。data_width从1'b1改字符串1是API表示规范化，两者都表示x16，不是变成1位。

col旧未显式、新显式10；rank旧1、新设置JSON不单列，单CS/rank接口保持。simulation旧关闭，新生成使用硬件控制器；没有运行仿真，也不把测试模型当实物验证。PLL_OUT_SEL明确4、生成5'd4；运行期间动态移相行为仍待校准。

固定/派生值也经过审查：tRFC350ns、tXS360ns保守保留；tRCD/tRP15ns、tRAS37.5ns/tRC52.5ns、tWR6CK，tREFI7800ns、tRL6/tWL5、REF_INTERVAL2995.2、DRAM_WIDTH16/ROW15/COL10/BANK3及BL8。API请求不等于所有字段都是可编辑用户参数；以上同时核对当前IP参数模板/生成器与实际生成宏，不接受未经核查默认值。

FIFO生成库子模块定义仍含通用默认FAMILY=TRION，顶层实例明确.FAMILY("TITANIUM")传递到内部；不能全文看到TRION默认字样就误判本工程仍选TRION。新RAM_STYLE/满空保护的解释见前节，配置一致性不是功能等价证明。
