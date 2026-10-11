# Codex A独立审查：264962e0

来源：用户在本对话转交独立Codex A完整报告；下文整理表格排版与证据，未由Work或内部代理冒充独立审查。

Branch：codex/m5b1-global-canny-prototype
Candidate/HEAD：264962e0c6af61e751c794c5b5f5252d00edbb6c
唯一Parent：c0102ee1c9a0a8aa802c398755d4a7b3139c7ffd
最终结论：**FAIL**。

本次candidate存在必须修复的问题，暂不能通过独立审查。主要问题位于实际显示接线和后台任务取消边界；编译、STA及已有模块测试通过不能覆盖这些缺口。

|严重程度|文件/位置|问题|证据|影响|建议|
|---|---|---|---|---|---|
|阻断 P1|rtl/m5b1_global_canny/m5b1_video_dma.sv:82；efinity/m5b1_global_canny_i3/src/lcd_driver.v:129|新DMA寄存输出与LCD驱动的一拍预请求不匹配|DMA在请求采样边沿才更新pix_data；同一边沿LCD将旧lcd_data寄存，而DE已经有效。逐边沿推导得到每行显示“旧值、p0、p1…p1278”，最后像素未落入该行有效区|每行首像素混入旧数据，其余像素错后一列；送入M5A的像素与坐标也不一致。这是新接线问题，不能豁免为厂商首行异常|修正请求、数据与DE的延迟关系；用实际video_dma→lcd_driver→M5A连接逐像素验收|
|重要 P1|rtl/m5b1_global_canny/m5b1_system.sv:19；rtl/m5b1_global_canny/m5a_copy/m5a_stream_top.v:51|无有效DDR回放的黑色显示帧仍可能被标为成功分类快照|DMA未满足offer/预填充条件时输出黑色并保留旧frame_id；display_valid没有传给分类路径。tap按光栅DE建立标签，capture只检查坐标、epoch、frame_id等，没有检查真实回放资格|启动或错过某帧回放资格时，可能捕获黑色替代帧，却沿用旧身份并置capture_success|将真实回放帧资格与frame_id一起锁存、对齐到分类tap；无效显示帧不得成为成功snapshot|
|重要 P2|rtl/m5b1_global_canny/m5b1_transfer.sv:26；rtl/m5b1_global_canny/m5b1_backend.sv:163；rtl/m5b1_global_canny/m5b1_global_engine.sv:143|尚未被仲裁器受理的C2请求不能取消，超时收尾可能永久等待|transfer在提交客户端请求时即置busy；若C2持续未获READY，则busy不释放。capture/export超时要求!tx_busy，engine进入ABORT后同样等待它；仲裁器事务watchdog尚未启动|后台服务持续不允许时，默认墙钟限制不能保证任务结束、释放状态并输出失败统计|区分“排队未受理”和“已受理在途”；超时可取消前者，后者继续排空，保留RT和真实B/R栅栏|

现有系统TB直接检查DMA的pix_data，分类输入另由合成三分类图提供；tap TB则直接注入灰度光栅。因此已有测试没有经过第一项问题所在的生产连接，也没有覆盖第二项的真实帧资格传递。未发现故意削弱测试的证据，但存在测试覆盖缺口。

## 只读核查与已有证据

- 实际差异298文件，与清单完全一致；逐项blob大小和SHA-256匹配。暂存区无变化，跟踪工作区干净；未审查或清理历史未跟踪资料。
- 已核查源码、顶层连接、TB/oracle、负向突变、SDC、构建输入输出及日志绑定。96项构建输入与最终文件一致，XML仅两项元数据变化可精确逆变换；53项构建输出及134份STA哈希匹配。85项M5A来源哈希一致，未发现保护工程提交差异。
- 独立解析STA最小setup/hold +0.190/+0.024ns；43227 XLR、124 RAM10、0 DSP。940个CDC选择器及413个数据目的端点记录一致，最大物理延迟1.316ns、组内skew 0.737ns。134份报告是路径覆盖文件数，不是134个PVT角点。
- 算法及已有测试支持完整八邻域传播、末像素sticky changed、真实metadata B后发布、642扫描BFS及默认超时不发布。十项HDL突变均有对应Fatal。独立运行不写文件的主机解码器自检，以及显示连接的内存逐边沿模型。
- 未重跑RTL仿真、综合或STA，未运行会写报告的验收脚本main。未验证实物DDR服务上界、真实场景发布率、30分钟稳定性、warm reset及跨PVT鲁棒性；未重新回放每个系统种子的UART原始字节流。
- bit核对一致且Git忽略：2881269B，SHA256 de1d9c565459e0cce4d4de37bc88a9616e99ac78fc0e27a785b5693da707f645。

## Codex A交开发者的最小修复清单

1. 修正生产显示路径延迟，增加经过真实LCD驱动的完整帧逐像素测试及错拍负向用例。
2. 将回放帧有效资格随标签对齐到tap；测试延迟相机启动、offer迟到和未达预填充条件。
3. 增加未受理C2请求的安全取消协议；验证持续禁止BG授权时超时能结束，已受理事务仍完整排空。
4. 修复后重新执行相关仿真、完整I3编译、STA和证据绑定，创建新candidate复审。

本轮Codex A未修改、暂存、提交或操作硬件，未获取另一位本次审查者报告。
