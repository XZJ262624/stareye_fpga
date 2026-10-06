# M3.1 离线验收报告

日期：2026-10-04。项目 m31_sobel_controls_i3，分支 codex/m31-sobel-controls。
冻结M3提交：7a9b448080fd6f1624c2ef37ee2eb267fed49c82。
结论：离线仿真、完整编译、已约束最终STA PASS；当时M3.1实物尚未验收；当前用户确认上板阈值正常，详见末节。本轮未运行Programmer、未下载、未写Flash，未提交M3.1。

## 修改与接口
工作副本：efinity/m31_sobel_controls_i3。新增 rtl/m31_sobel_controls/m31_controls.v、m31_osd.v；副本顶层接控制器及OSD，SDC增加定向按键同步例外。官方EfxProjectDatabase/DesignAPI保存工程、check/generate接口。
K1=N2/GPIOL_P_02、K2=M2/GPIOL_N_02，Bank1A、1.8V LVCMOS、低有效、外部10k上拉。K3=CRESET_N不使用。证据为参考核心板V1.4原理图p3/p7、厂商按键例程、官方封装及配置模型；用户实物为V1.5，版本边界保留。
关键纠正：M3接口原本将N2/M2分给旧LCD的lcd_de_o和lcd_pclk_o，后者实际clkout，不能当空闲输入。仅M3.1删除这两项并新增按键输入，其余全部接口组件保持不变。当前M3运行时不要按K1/K2；M3.1未来也只在user mode按键，禁止在上电/配置期间按键。
原AR0135、DDR、HDMI参数、PLL、分辨率、两行缓存、窗口及五个Sobel核心RTL逐字未改。1018受保护文件哈希均一致。

## 操作语义
K1按下再释放：阈值+16；K2：-16；0..255饱和，无长按连发。
两键在同一消抖手势中被检测到，全部释放后只切换一次模式，不调阈值；循环 BIN→RAW→MAG→BIN。
双级同步，实际74.4MHz像素域消抖1,488,000周期=20ms；复位后先连续确认全释放20ms，启动时按住不触发。阈值复位64，模式BIN。
pending值只在VS下降沿应用；与释放事件同沿则下一帧生效。OSD显示已生效模式和T000～T255。OSD位于核后，像素/DE/HS/VS统一增加一级，完整为六级采样（输入采样后第五个周期输出）。原算法slot右下偏移策略保留。
没有新增多位异步控制CDC。定向例外只到key_meta第一FF的D，匹配数每键必须恰为1，第二FF正常计时。

## 仿真与自动验收
ModelSim SE-64 10.1c -novopt；控制25项、实际20ms消抖、256阈值BCD及字体逐像素、1,638,400栅格像素、765,952 OSD像素、9帧160×40缩小栅格、57,600有效像素/60,503周期端到端独立Sobel黄金模型和同步全部通过。
主会话独立检查源码、全部256值BCD、原接口差异、受保护哈希、原始时序并实际重跑最终仿真与验收。脚本自身、顶层、五核、TB、日志和像素dump绑定哈希；dump保留本地但忽略Git。
真实子进程1个完整正向控制、25个负向用例全部拒绝：失败阶段、错误模型/负裕量/漏约束、缺报告、陈旧源码/bit/数据库/仿真脚本/日志/dump等。见negative_acceptance.json及negative_binding.json。
首次布局布线因不支持get_registers失败，证据保存build_failed_01_sdc；改官方get_pins -regexp后重新完整编译。主会话另纠正验收器将CLK/D完整端点后缀误判的问题，不改实现。

## 最终编译及实现时序
Efinity2025.1.110.5.9，Titanium/Ti60F225/FBGA225/I3；map/interface/pnr/pgm全部PASS。
隔离最终实现副本生成94份报告；最终outflow/work_pnr未被审查改动，bit/LPF/LBF与clone绑定。证据见build/result.json、final_audit/binding.json、ACCEPTANCE.json。
最小setup +0.187ns，hold +0.019ns；像素域setup +6.255ns、hold +0.036ns；HDMI全部30输出位setup +11.239ns、hold +0.036ns；两个key_meta→key_sync各setup +12.993ns、hold +0.109ns。
no_clock=0、unconstrained_internal_endpoints=0、multiple_clock=0。no_input_delay=7（原5个及2机械键）；no_output_delay=135（原136减旧lcd_de_o），这些继承外设和异步端点不代表全部外部接口已获得新增电气验收。
XLR7111/60800，RAM10块50/256，DSP0/160；两行缓存实现未变，无新增RAM/DSP。较窄hold裕量保留，不宣称实物温压裕量已经验证。

## 告警与保留风险
warn.log追加两轮记录共604条，不能误报为本轮604条。最终一轮302条，对照M3的303条、归一化路径/行号后无新增，少旧lcd_de_o未驱动告警。新控制/OSD无综合告警。继承DDR IP截断/空端口和未用厂商外围接口分类保留，不能凭本轮仿真宣布修复。官方接口生成3条原有距离提示保留。详见WARNING_REVIEW.json。
PLL LOCKED异步复位、原厂CDC/DDR约束假设、相机2.8V与板卡接口边界、旧Flash流水灯冷启动风险均保留。
静态散斑原因未确认：阈值/曝光增益/传感器噪声为待比较假设，没有证据确认DDR或窗口故障。初始化写305E=0020、3012=960、3100=0013且注释自动DG/AG/曝光；非实时读回，不修改相机。

## Bitstream与停止边界
路径：F:/Projects/stareye_fpga/efinity/m31_sobel_controls_i3/outflow/Ti60_Demo.bit
大小：2151513字节。
SHA-256：405f255851a0ad5fc3961994f5a73579afb17009a1f60dc44d85b6c2abf9a639。
bit/outflow/缓存/锁/临时dump/negative_cases均忽略，不自动提交。未来实物验收和旧Flash安全另行处理，当前暂停在离线完成。


## 2026-10-06 M3.1基线签收与归档
当前已完成控制、消抖、帧边界更新、RAW/MAG/BIN和OSD的既有离线验证；用户此前确认M3.1已上板且阈值调节正常。用户未提供M3.1独立长时或跨PVT验收，不补写。旧文中未上板、未提交是2026-10-04离线记录；本轮授权将M3.1基线先独立提交。
现有工程XML较历史构建保存了GUI运行状态及显式ooc=false；通过完整重复节点规范化与官方schema缺省false核对，功能参数等价，原XML不覆盖。编译时project_before/after.xml保留构建快照；当前GUI状态不冒充新的编译证据。本轮没有重新编译或操作硬件。

## 归档证据与重放边界（2026-10-06）
主会话与Astra独立核验94份历史最终STA，最小setup/hold为+0.187/+0.019 ns；保留的work/audit_20261004_120245副本bit、LPF、LBF均匹配历史构建及最终绑定。原outflow有25项缺失、6项改变，当前原目录验收器不能完整重放；本轮没有恢复生成物或重新编译，不宣称当前原目录完整验收器PASS。完整差异及证据见PRECOMMIT_EVIDENCE_CHECK.json。GUI XML仅运行状态及显式ooc=false变化，完整递归规范化与官方schema证明功能参数等价。日志、work、bit和数据库不提交，源输入、历史JSON绑定与STA文本报告归档。
