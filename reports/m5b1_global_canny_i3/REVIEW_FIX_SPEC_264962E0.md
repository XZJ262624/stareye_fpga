# M5B.1双审查FAIL后的冻结修复规格

状态：FROZEN_FOR_REPAIR；Work于2026-10-10收到用户转交的Codex A完整FAIL报告。
分支：codex/m5b1-global-canny-prototype。
唯一开发起点及新candidate直接parent：264962e0c6af61e751c794c5b5f5252d00edbb6c。
Codex A：FAIL，三项必须关闭。DeepSeek B：PASS_WITH_FINDINGS。Work采用FAIL，未放行实物或M5C。

## R1：真实生产显示连接

关闭DMA寄存数据与lcd_driver一拍预请求的新增错位。逐边沿明确pix_request、FIFO byte/pop、pix_data、lcd_data/r_lcd_rgb、DE/HS/VS与M5A输入的关系；不得以vendor首行异常、静态图无法观察或统一挪动黄金图掩盖新错位。优先在新DMA/新顶层适配现有lcd_driver契约，允许必要的新工程复制件小修改，但不改旧工程或720p/时钟/管脚/原显示模式语义。

验收必须实例化实际生产lcd_driver与video_dma，走实际生产接线进入M5A；使用非均匀行列身份图覆盖完整1280×720、每行首末像素、跨行、跨帧和首个有效帧，不仅观察DMA输出。逐像素核对LCD灰度+DE坐标、M5A分类tap身份/黄金结果及原七模式输出回归。恢复旧一拍错位的真实HDL负向变体必须被此连接oracle拒绝；编译错误或无关超时不算kill。合成分类系统TB与直接灰度tap TB继续保留，不能代替新增连接测试。

## R2：回放有效资格与分类标签

将真实DDR回放资格与frame_id/epoch作为同帧身份锁存并对齐到分类tap，覆盖第一/最后像素及CE停顿、流水线跨帧。没有offer、未满足4096B预填充、run尚未有效或失效的黑色替代帧不得获得成功snapshot身份。全零但真实有效的DDR帧必须允许成为合法快照，禁止按像素值判断有效性。

标签队列在无效帧、有效帧、帧中失效和reset/epoch后必须正确推进，不得因门控tap_valid遗留旧tag、死锁或错借下一帧身份。不能反压M5A光栅，原局部显示保留。明确选择跳过无效帧等待下一有效SOF，或以失败终结本job的策略，并在默认墙钟内闭合。

验收：延迟相机启动；offer迟到于首像素；0/4080B拒绝、4096B准入；空白替代帧与合法全零帧；连续无效→有效；有效→无效→有效；首末像素资格及frame_id/epoch/timestamp一致；必要的中途失效应失败且不发布。注入旧行为（无资格仍成功捕获）必须由同一真实连接oracle拒绝。

## R3：C2未受理请求取消与已受理事务排空

区分transfer内部排队/尚未被arbiter客户接口受理，和客户握手后已由arbiter持有的在途事务。为后台capture、engine ABORT与export timeout建立明确的本地取消终结路径。取消未受理请求不应依赖将来safe_window/READY；不得通过伪造ddr_reset_ack、全域复位、放宽QoS或影响RT来解锁。

取消与客户READY同拍时采用有文字与断言的原子优先级：若客户握手发生，必须保持owner/payload和DDR侧stalled VALID，至真实B/最后R完整排空；若取消获胜，arbiter不得受理或生成孤立下游事务。下游A尚未握手但arbiter已受理仍视作在途。真实协议卡死保持既有fail-stop/no synthetic ACK边界，不宣称有限时间完成卡死DDR事务。

考虑4KiB逻辑请求分段中间等待受理：可安全取消剩余未受理片段，但必须失败且不发布部分结果，已完成真实事务不得回滚/清假账。取消、拒绝与done/error只能产生一次可消费终结事件；采集FIFO/drain、descriptor、result reserve/lease和packet半包必须正确释放，保留旧有效结果与失败统计。

验收分别持续禁止BG授权（safe_window=0且RT继续正常）使capture、engine、export停在未受理状态，触发各自默认墙钟并确认有明确推导预算的收尾和CRC有效失败统计；测默认上限与缩短参数测试一致的语义。还须覆盖取消同拍READY、arbiter已受理但DDR A背压、W/B背压、R末拍背压、分段边界取消、拒绝同拍、后续job恢复。接受/完成/取消/inflight逐拍守恒；未受理取消不得新增DDR事务计数。恢复旧不能取消的HDL变体必须被该oracle拒绝。

## DeepSeek B非阻断项

保留真实加密DDR非零ID回声待实物验证、warm reset未证明、4us仅条件模型、外部I/O/134报告与PVT边界。不得为规避ID风险去除RESP/ID/LAST检查。
可在本修复范围内说明并验证根Ti60_Demo.pt.sdc非活动，所有实际构建/STA只用权威I3约束，不让旧整域false path混入；copy_mem末拍越界读可做明确有界索引的小修复，但不扩大算法/资源/接口目标。UART加速测试与生产baud、min水位含合法空态的披露保留。

## 范围、验证、Git与停止

允许：rtl/m5b1_global_canny、tb/m5b1_global_canny、efinity/m5b1_global_canny_i3的新顶层/必要复制件/约束、scripts/m5b1_*、reports/m5b1_global_canny_i3与必要docs/STATUS、HANDOFF、PROJECT_BRIEF、DECISIONS。旧M2～M5A/M5B0/R输入/输出只读；DDR IP/ROM/管脚/PLL/720p/七模式不变。不得实现M5C/static_mask/融合/识别。

先实现和运行三个真实复现/负向用例，再修复并重跑相关及原冻结全套离线门。修改生产RTL后完整I3 map/interface/P&R/离线bit生成、资源、精确CDC结构/选择器/413数据预算与新STA必须重做，不复用旧bit/资源/时序宣布新candidate PASS。原始失败证据、原candidate报告和旧bit元数据保留，以新输出目录/带标识记录新证据，不清理未知未跟踪。

原64pair/1秒、48640 XLR/204 RAM10/128 DSP闸门不放宽；内部no_clock/unconstrained/multiclock=0。全部报告绑定最终源码与实际构建输入/bit SHA。保护旧资料及历史未跟踪；读取当前父提交，修正旧验收/scope脚本中c0102ee1硬编码以支持追加修复candidate，不能放宽精确scope、空索引、干净跟踪、blob等门槛。BASELINE_PROTECTION包含历史路径，不对外发送；新修复快照也必须只提取固定Git技术blob。

精确逐文件暂存，不git add .或-A；不amend/rebase/改写历史/merge main/push。新candidate必须直接继承264962e0；交回branch/candidate/parent/scope、三个关闭证据、全部测试、完整构建/STA/资源、新bit元数据、已知边界及工作区状态，然后立即停写。Work独立复核、自动新DeepSeek B盲审快照并停下交用户独立Codex A复审提示词。不得提前操作Programmer/JTAG/SPI/Flash或宣称实物PASS。
