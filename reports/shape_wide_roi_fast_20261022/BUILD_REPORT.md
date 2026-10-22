# 扩大识别区域：快速增量交付

**未提交冻结快照，等待用户独立Codex A审查；尚未放行实物。**

基线HEAD `9dea12d9f0d29f57aa6d3acb75695da9e0d53d2c`，parent `973f6cc2bd997a2f375d1bdb4834ffef8435369c`，branch `codex/m5c-fusion-prototype`。无新candidate、无Git暂存/提交、无DeepSeek B调用、无硬件操作。采用2026-10-22用户授权快速流程：针对性自检/必要构建→A→用户上板→成功再提交，B提交后补审。

## 变更

新工程 `efinity/shape_wide_roi_i3/Ti60_Demo.xml`。ROI为x160..1119/y90..629，即960×540；保留16px边距，允许处理后边缘bbox宽高80..440。新recognizer使用540×26bit行表、10bit局部坐标/行地址，精确518400 ROI像素，帽区碎片计数4bit饱和15。OSD绿色静态框同步扩大。逻辑差异只有两份新RTL和XML的两条模块路径替换，91项源码中其余88项与父版本对应内容一致。

继续完整EOF后分析、原32768拍预算、原中心误差16/圆弦长/矩形/多段拒绝条件。H64默认、GAU、COV/RAW/CNY、PREV、相机C000镜像修正、时钟/管脚/720p、DDR/FIFO/CDC均未改变。没有条纹过滤、CCL/run表、最大轮廓或提前ROI分析。

## 实际验证

- 41项定向RTL覆盖bbox79/80/280/281/384/385/439/440/441、圆/矩形/三角/环/文字/双目标、四侧16px边距、518400精确计数、ROI末行末像素26bit写入、缺失/重复/错坐标、support/config/source/frame失效、CE暂停、reset/SOF/FINISH抢占与恢复。
- h440帽区7行允许、8/14行拒绝；h500域外样本真实16碎片计数饱和15且拒绝，避免旧3bit饱和7在大尺度绕过预算。
- 实测有效440目标分析1826 accepted-CE；定向最大2066（包含域外h500），均小于原32768预算。
- 生产adapter + 新recognizer/OSD的2个完整1280×720光栅及下一SOF，共1843201 active采样、5992新框像素；前帧结果身份和显示、旧框移除、其他像素/OSD及一拍DE/HS/VS、CE保持通过。
- 复用未改上游历史证据。本次没有新完整DDR/DMA/GAU系统72帧回归，2帧定向链不能冒称整系统72通过。
- 一次fresh map/interface/place/route，17组原精确CDC选择器在新map与原生工具中检查，SDC不变；basic I3 normal setup/hold及内部未约束检查通过。没有全6731FF/579metadata/全clock-pair重复审计。

资源：XLR **15309**、RAM10 **106**、DSP **9**。normal setup/hold最小 **+0.198/+0.026 ns**。check_timing计数：`{"no_clock": 0, "unconstrained_internal_endpoints": 0, "no_input_delay": 7, "no_output_delay": 135, "multiple_clock": 0}`。继承6条PLL异步SR未计时、外部7输入/135输出及PVT/warm-reset限制保持，不能把basicSTA写成这些旧边界已关闭。

## BIT与审查

文件：`reports/shape_wide_roi_fast_20261022/artifacts/StarEye_Shape_WideROI.bit`；大小 **2312202 bytes**；SHA-256 **`7b92293979d8169e8f8ff77a65131cf2452699aea1929ab362fec616316b466a`**。由本次路由DB离线生成，使用efx_run --flow pgm只生成文件，未运行Programmer/--program/下载/Flash。源码/SDC/路由DB/实际日志绑定见BUILD_RESULT.json与BIT_INPUTS.json。

review_snapshot保存本轮完整91项必要编译源码闭包、定向测试/TB/新输入、必要报告/日志和BIT。所有快照项均逐文件size/SHA绑定；不包含Git元数据、工具包或原1.65GB黄金资产重封。快照不是commit，必须按此快照审查，禁止审查持续变化工作区。A通过后仍需Work单独交付指定BIT和实物清单。

## 已知限制与执行失败记录

大框/尺寸扩展没有提升杂纹抗扰：原整ROI轮廓算法仍会因细条纹、背景边、近距越界、明显旋转等UNKNOWN。440是边缘bbox，不是原图名义尺寸；先前新GAU主机模型中名义440变441而拒绝，438变439可过。

首次ModelSim沙箱启动发生Windows DLL重定位错误，改用获准的本机工具执行后正常。OSD第一测试在reset释放前检查正常视频输出，6ns误失败；仅修TB scoreboard启用时机，核心41例不重跑，OSD定向重跑通过。首次静态map解析遗漏剥除Verific块注释，错误只解析出1个cell；仅修Python解析器，原map/interface不重跑，SDC/RTL未改。以上原失败文件保留，不冒称生产故障或隐藏重跑。
