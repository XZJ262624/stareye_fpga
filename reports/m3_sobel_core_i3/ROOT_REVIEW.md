# M3 主会话独立复核

2026-10-03。实现代理：GPT-6 Astra（gpt-6-astra），reasoning_effort=ultra；最终复核：主会话。Astra交回写入权后，主会话仅更新审查记录和交接文档，未修改冻结RTL、工程输入或实现输出。

**结论：M3离线仿真、完整I3构建及已约束STA通过；Sobel实物未验收。** [实际复核记录](ROOT_REVIEW.json)、[完整构建报告](BUILD_REPORT.md)、[最终验收](ACCEPTANCE.json)。

## 独立核查及证据

| 核查 | 主会话结果 |
| --- | --- |
| 接入来源 | 对照M2已编译源快照和M3顶层diff：DDR R0_FIFO_8→8位lcd_driver→Sobel→RGB复制；原lcd_request和未延迟的~lcd_vs反馈保留。验证了真实FWFT FIFO与LCD的双帧仿真，未根据命名推断时序 |
| 五个RTL | 逐份检查两行RAM、无跨行窗口、11位有符号梯度、12位L1、8位饱和/阈值、有效信号、复位同步释放、帧重启及显示模式 |
| 坐标/边界 | 输入槽位(x,y)输出中心(x-1,y-1)；上两行/左两列算法无效并显示黑色；完整DE不裁剪。五次寄存采样，输入边沿n至输出n+4，明确右下各一像素位移 |
| 独立算式 | 不调用子代理黄金卷积函数，直接读取实际HDL九像素窗口，复算426+640个有效结果的Gx/Gy/绝对值/幅值/阈值、坐标、模式和同步；全部匹配。3×3用例阈值0/64/255各覆盖160个有效窗口 |
| 测试覆盖 | 检查实际TB与stimulus：黑白、递增、水平/垂直/对角边、脉冲、最后像素、停顿、连续异图帧、异步复位/半帧丢弃；非时钟边沿复位有断言。两帧720p共1,843,200 DE像素、1,835,208窗口；映射RAM26,882像素/16,642次两行读取 |
| 负向控制 | 主会话重新执行8种正常证据和26种损坏证据CLI；正常全部退出0，损坏全部退出1且诊断原因匹配，排除“脚本始终拒绝”假通过 |
| 真实行RAM | 检查最终map中4个EFX_RAM10，分别组成两条1280×8行；READ/WRITE_WIDTH=4、OUTPUT_REG=0、READ_FIRST。仿真副本仅隔离无关加密DDR实例，其他首模块内容逐字对应，不宣称完整DDR门仿真 |
| 器件/接口 | 当前官方工程Titanium/Ti60F225（F225/FBGA225）/I3/example_top，工具2025.1.110.5.9；对照69文件快照，旧IP/SDC字节不变，外围XML只有保存时间变化 |
| 构建绑定 | 独立调用validate()与保存ACCEPTANCE完全一致：74输入、真实各阶段返回、最终DB/bit/90份STA及仿真源和输出哈希通过；项目构建前后仅允许XML保存时间变化 |
| 最终STA | 直接读取原始Slack：全局setup/hold +0.102/+0.027ns；像素域+7.419/+0.031ns；30路HDMI +11.297/+0.039ns；81个DDR出口+0.556/+0.103ns |
| 时钟覆盖 | no_clock、unconstrained_internal_endpoints、multiple_clock均0；保留5输入/136输出未设置I/O delay的既有例外，不能称全部外部路径受约束 |
| 资源 | 最终place报告6535/60800 XLR、50/256 RAM、0/160 DSP；相对M2增加307 XLR与4 RAM |
| 告警 | 仅比较各warn.log最后一次综合，保留消息中的数值位宽，仅归一化工程路径和末尾行号：M2详细303→M3详细302，新增0，移除rframe_data 16/8宽度告警；各另有100网表告警汇总一条。RAM初始化/窄WE映射信息与既有硬件风险分列 |
| M2完整性 | 735个可读文件的SHA、大小、mtime不变；原736路径中仅不可读临时.lock消失，未推断原因。69个已编译源快照逐项一致 |
| Git | feature/m3-sobel-core，HEAD仍9a6d33db4dd3d5f6842cd43661a9a35409eadf1e，暂存区为空。精确M3 -text规则与生成物check-ignore已实际核验，无add/commit |

## 复核后修正

补充8种正向控制及负例预期原因；补足最小3×3阈值/模式轮换和真正异步复位断言；核实最终映射RAM行为。上述测试修正已进入最终仿真/负测绑定。README、状态、交接及阶段定义已按用户本轮M3授权同步，原M4基础Sobel前移M3，M4剩余范围仍待确认。.gitattributes新增精确M3字节保留规则，防止未来换行转换破坏证据哈希。未因消除告警更改已验证相机/DDR/HDMI参数。

## 仍保留的边界

Sobel尚未下载或上板。旧Flash官方流水灯的R3/R4共享脚冷启动风险、PLL/既有复位和CDC、相机电气及I2C驱动方式、DDR校准信号/压力/全容量/温度等仍待专项验证。有限仿真和已约束正裕量不关闭这些事项；本轮没有硬件操作或Flash授权。

bit路径：`F:/Projects/stareye_fpga/efinity/m3_sobel_core_i3/outflow/Ti60_Demo.bit`；2,141,760字节；SHA-256 `eb8f1d9d586a319d8c18e37ea3e577c445b4a538d70c7fcd4d681832675fcb1b`。

拟提交逐项路径/大小/SHA见[CHANGE_SCOPE.json](CHANGE_SCOPE.json)，分组见[CHANGE_SCOPE.md](CHANGE_SCOPE.md)。未跟踪的M2附带文件、reference和tools保持原样且不在范围内；bit、outflow、构建缓存、映射仿真副本、波形及临时负例均排除。
