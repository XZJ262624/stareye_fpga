# M3.2中值滤波交付审查与离线集成报告

更新日期：2026-10-06。交付模块结论 **PASS**；整链路结论 **PASS（离线）**，允许进入整机集成且该离线集成已完成。此前离线归档时实物尚未验收；现已完成用户实物签收，详见末节及ACCEPTANCE_REPORT.md。

## 审查范围及执行者
用户指定GPT-6 Astra / ultra完成交付静态与架构审查。主会话独立安全解包、核验、源码复核及排序黄金重跑。Astra后续代理触发使用限额，主会话接管新工程的测试、整改、双构建与最终证据绑定。未把队友PASS当作本轮执行证据。

ZIP与79个解包文件完整核验见[模块报告](../m32_median_review/MODULE_ACCEPTANCE.md)、[完整交付清单](../m32_median_review/FILE_INVENTORY.csv)、INTAKE_INTEGRITY.json；77行CSV、78行SHA的非自哈希规则匹配，无缺失、多余、重复、大小/哈希错误。ZIP为58,427,385字节，解包75,382,662字节。压缩文本波形只作证据，不是未知二进制。

## 架构和接口
输入来自DDR读出后、原灰度复制到RGB前的lcd_gray/lcd_de/lcd_hs/lcd_vs，使用clk_pixel与rstn_pixel。相机、DDR、HDMI、PLL/SDC/管脚和原Sobel/按键/OSD核均保留。输入8位无符号灰度；median_3x3为九级奇偶交换排序，36组比较，取第5个值；输入p00..p22按上至下、左至右，对重复值/0/255正确。两行缓存无整帧缓存，单独模块首两行/列无效，中心为右下槽位(x-1,y-1)。

集成必须补偿中值中心坐标：23位包携带原灰度、阈值、模式、滤波标记和DE/HS/VS/SOF，1662地址的BRAM环延迟1661拍，读写始终不同址、不复位RAM、填充期间不暴露旧数据。每拍包含空白均前进，不在SOF清环。滤波请求仅SOF起沿生效，旁路/滤波同光栅、Sobel按完整DE计数。

RAW始终原灰度；MAG/BIN为可旁路中值后Sobel与8位阈值。滤波时要求完整5x5支持：Sobel右下槽位3≤x≤WIDTH−2、3≤y≤HEIGHT−2，否则MAG/BIN黑色，DE不裁剪；旁路保持M31边界。输出原图、梯度、二值、中心坐标等接口预留供后续彩色组合，当前HDMI仍灰度三通道复制，未实现彩色叠加。

| 观察点 | 相同输入像素在n采样后的时刻 |
| --- | --- |
| 独立median核心 | n+8 |
| 独立median流包装 | n+10 |
| 重锚光栅包 | n+1661 |
| Sobel输入采样 | n+1662 |
| M32流出口 | n+1666 |
| OSD/最终像素出口 | n+1667 |

相对原M31最终显示n+5，旁路整体后移1662拍。有效支持边界是空间限制，与时钟流水线延迟区分记录。像素时钟与1280×720分辨率未改变；继承实际74.4MHz和1650×750光栅，不能仅凭名义文件名说PLL恰为74.25MHz。

## 验证
队友全部六用例实际重跑：3,239,333周期、2,090,089有效结果、两完整720p帧，九负向测试均返回非零。主会话独立sorted()[4]黄金：全部362,880个1～9排列、512二值窗口、20,000随机窗口；387,013核心周期、380,486有效结果；22独立小帧及复位/停顿/边界/椒盐/帧切换、额外负向均通过。

整链路独立二维中值+Sobel+字体黄金见sim/binding.json：18帧160×40覆盖RAW/MAG/BIN、0/64/96/128/255阈值、原图与椒盐/边缘/随机图、帧内反向请求、帧边界滤波切换、环反复回绕、复位重新填充和匹配同步；两个完整1280×720帧使用真实HT=1650/VT=750、HS=40/前有效区260拍、VS=5/前有效区25行。逐周期检查DE/HS/VS、模式/阈值/滤波标记和输出，DE期间坐标/中心严格比对。旁路同时实例化原M31链，逐像素比较其延迟1662拍后的OSD最终输出。未仿真传感器模拟电气或DDR全容量/校准压力，不扩大已验证基线的范围。

最终自动验收1正向、17真实CLI负向（坏状态、缺帧/像素、来源/bit哈希、缺报告、错误SDC/Tcl/数据库证据、负裕量/错误型号/空时序）均按预期退出；整链路两个故意错误像素黄金均被识别。初始ROOT向量True/False格式、OSD黄金一拍同步比较和STA缺环境变量为测试/运行环境问题，均修正；RTL不因这些问题被误判故障。

## 修改和构建
必要交付文件仅median_3x3.v/median_stream_top.v；复用原行缓存/窗口与Sobel。新增raster_packet_delay.v、m32_stream_top.v、测试与新scope脚本。新顶层替换显示后处理接入，经官方EfxProjectDatabase增加源文件并设置启用变体参数1；原版默认0。只移动新副本中的SIM_DATA=0声明到正式顶层参数列表，保留原默认及可配置语义；显式扩位后截取环地址，消除新增隐式截断。无需重生成物理接口/IP，相关文件逐字复制且编译前后不变。

两套均完整interface/map/P&R/bit生成通过。最终实现lpf/lbf、bit、输入源码、94份最终I3 STA、仿真脚本/模型/日志/数据分别绑定；见ACCEPTANCE.json和各变体build/result.json、final_audit/binding.json。下列具体资源、时序与bit信息由最后一次实现提取。

## 告警与限制
最新map.out为304个WARNING行（含汇总、与M31同口径一致）；规范化新消息及新增出现次数均0。旧文档302统计口径和追加warn.log不可直接用作此次告警总数。之前试编出现SIM_DATA成为localparam、环地址隐式截断两项，均在最终源码/最新综合中消除，追加日志仍保留历史消息。继承DDR加密IP位宽、未用端口和100个后综合网表提示，不将其泛称新增故障；详细分类在WARNING_REVIEW.json。

no_clock/未约束内部端点/multiple_clock均0；7个无输入延迟、135个无输出延迟为继承异步/未用外设及专用接口边界，已约束STA通过不等于全部物理接口专项验证。PLL LOCKED异步复位/失锁恢复、窄正hold、旧Flash相机共享管脚冷启动、噪声/曝光/增益原因均保留。中值改善散斑程度尚需实物对照。

固定光栅重锚只支持当前连续有效行和1650拍行周期，不支持任意valid停顿重锚；独立median模块的停顿测试仍通过。滤波默认旁路，可用两构建比较；原两键只调阈值/模式，未增加硬件滤波菜单。当前综合保留两变体中的中值RAM，不能假定常数旁路已裁剪所有滤波资源。

## Git与停止边界
历史离线归档时分支codex/m32-median-integration，父提交7a9b448；M31原工作树未提交，不虚构M31基线提交。原1,412文件内容、大小、mtime核验不变。完整拟提交清单见PROPOSED_GIT_SCOPE.json；是可审阅列表，不是已暂存文件。排除handoff/、outflow、work*、bit、缓存、大型仿真数据、reference/、tools/和厂商资料。未git add/commit。编译后已暂停，不Programmer、不JTAG、不SPI Active操作、不写Flash，未宣称实物中值通过。


## Final implemented results

| Variant | XLR | RAM | DSP | Minimum setup ns | Minimum hold ns | Pixel setup/hold ns | HDMI setup/hold ns |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| m32_median_integration_i3 | 8082 | 59 | 0 | 0.198 | 0.013 | 7.129/0.029 | 11.115/0.039 |
| m32_median_integration_enabled_i3 | 8158 | 59 | 0 | 0.194 | 0.026 | 7.464/0.034 | 11.148/0.043 |

- m32_median_integration_i3: `F:\Projects\stareye_fpga\efinity\m32_median_integration_i3\outflow\Ti60_Demo.bit`; 2170446 bytes; SHA-256 `1f174e133ba6d7f0f7ddb3df2015efbf8ce22203fa71da1be6769946c3e1b0b9`.
- m32_median_integration_enabled_i3: `F:\Projects\stareye_fpga\efinity\m32_median_integration_enabled_i3\outflow\Ti60_Demo.bit`; 2172438 bytes; SHA-256 `6a072ab553de7e1ae6e2fc0013eac280d32d7664a19cc51d8a89c0514156d71d`.

Both variants retain median row RAM=4 and packet RAM=5 under inherited synthesis settings. Hardware configuration and other source files: 134 equality checks against the frozen M31 input copy. Integrated independent comparison: 2,649,733 cycles / 1,958,400 DE pixels / 1,935,800 valid windows; 979,200 exact bypass+OSD equivalent display pixels. Two negative gold controls and 17 CLI acceptance negatives passed.


## 2026-10-06当前实物签收（优先于此前离线阶段的待验证文字）
M3.2交付模块验收PASS，整机离线集成PASS，实物功能与当前运行条件下的稳定性验收PASS；窄hold裕量及跨PVT鲁棒性作为保留边界。详细反馈与镜像只读核验见[ACCEPTANCE_REPORT.md](ACCEPTANCE_REPORT.md)。BIN高阈值抑制低幅值响应，两版差异小合理；MAG像素不由阈值改变，观察只按用户反馈归档；中值在低阈值下减少孤立噪点并保留主要边缘。长时观察是本次条件下补充证据，未提供具体时长和PVT范围；启用版最终STA保持+0.194/+0.026 ns，窄hold与跨PVT未严格证明。本轮只归档与Git提交，不重新编译、不Programmer/下载/Flash、不M4；旧Flash/R3/R4风险不关闭。

## 归档重放前提
历史交付独立审查及一次性configure脚本仍需本地被排除的handoff交付内容；清洁checkout不能直接重放全部历史脚本。整机仿真/构建的必要源码依赖完整入库。当前scope.py为历史未提交状态的清单生成器，不应直接用于本轮两次提交；以更新后的PROPOSED_GIT_SCOPE.json及Git实际提交范围为准。原始日志、数据库和镜像留在本地不提交，JSON绑定保留其哈希。

## 本轮Git归档
M3.1独立父提交：742d8a461b36f5970f7caea04fb8f8c925fe8a02。M3.2默认旁路与启用变体及本次实物报告将独立提交；精确范围见PROPOSED_GIT_SCOPE.json。仅文本源输入和证据入库；镜像、数据库、日志、缓存、reference/tools及原交付ZIP均排除。自身提交号以git log为准。
