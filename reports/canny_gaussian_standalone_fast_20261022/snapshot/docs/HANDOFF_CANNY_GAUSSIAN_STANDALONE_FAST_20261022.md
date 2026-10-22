# 双路Canny＋高斯独立版：快速流程冻结

用户2026-10-22明确授权：现在实施双路Canny＋高斯滤波独立版，并同时纠正旧双路Canny左右镜像；到用户独立Codex A节点停止。按快速流程，不提前Git/不提前B/不硬件。

## 身份与单Writer
当前branch codex/m5c-fusion-prototype，HEAD b5f36414035193ab9c7aa8393732a93e10fe141e，parent9dea12d9f0d29f57aa6d3acb75695da9e0d53d2c。Astra High唯一技术writer，Work只写调度文档和核收。现有大量其他跟踪修改和未跟踪历史文件不得清理、覆盖、暂存、提交。识别独立版及旧M2～M5C/gaussian工程/远端冻结输入全部保护。

允许新增rtl/canny_gaussian_standalone/、efinity/canny_gaussian_standalone_i3/、tb/canny_gaussian_standalone/、scripts/canny_gaussian_standalone/、reports/canny_gaussian_standalone_fast_20261022/。可只读引用可靠基线未修改模块，必须列真实编译闭包，避免重复module及无意引用正在变化的工作区。需要新增范围时先报告Work，不能修改旧生产工程。

## 目标与最小架构
独立边缘演示镜像，保留实时局部Canny-lite、DDR低频完整八邻域全局Canny、现有保守融合补边/红局部优先青新增及合法身份/TTL/源资格/真实排空保护；新增或复用已验证高斯3x3前处理，保留可演示的中值比较及七模式/阈值控制。独立版不实例化形状识别/PREV/识别框；优先移除非必要pair采集、影子诊断、完整UART图导出，不动旧诊断版本。移除UART时必须检查lease、slot选择、writer/reader仲裁等耦合，不能假接ACK或绕过真实B/末R。不要额外实现分块融合、自适应阈值、抗条纹或其他新算法。

先给Work简短架构方案和真实源依赖差异：选择821387c4系已有实物融合基线或已验证gaussian_integration内核，核MED/GAU配置切换/身份完整性，避免把带识别/成对诊断的大整合版本整套搬入。若切换控制需要确定映射，采用最少用户操作且与已有七模式/双键融合约定协调，明确报告，不擅改顶层时钟/管脚/分辨率/传感器曝光。

镜像：使用已审已实物确认的AR0135 READ_MODE寄存器3040=C000（原8000，仅bit14水平镜像变化，保留bit15），在新工程拷贝LUT里修改；原9dea12d9的I2C串行验证及位语义可复用，仍检查本新实际连接确实使用修正LUT且stream-enable前仅写一次。保持OSD正常方向，不在末端反转整屏或仅反转OSD；不修改原双路Canny工程。

## 必须复用的失败经验
旧高斯圆帽整合远端V1的SYSTEM_WATCHDOG healthy=0/published=3并非已证明算法错；docs/HANDOFF_GAUSSIAN_CAP_REMOTE_V2_SCHEDULER_FIX_20261021.md和STATUS记录为测试台每帧切模式导致MED/GAU generation持续变化、正确拒绝旧结果。V2只修夹具，未收到完整新结果，不能冒称全通过。新测试必须稳定当前filter/config到真实新健康帧再切，不放宽TTL/身份/4秒旧门以伪造通过。旧physical失败/恢复和宽ROI/识别版本证据不等于本版物理成功。

## 快速但有效的验证
先短链定向：GAU整数gold及边界/CE/EOF、MED与GAU切换代际、局部分类与全局BFS一致性、融合真实源/TTL/身份及红青覆盖对齐；代表性弱连通案例应在实际生产链产生青色，阴性旧源/错身份必须拒用。只测改动或拆除所影响的lease/请求/排空，不重所有旧资产。
至少少量完整720p实际生产SUT连接帧，覆盖稳定MED/GAU、背景全局发布、融合启停及阈值换代后恢复，真实DDR B/末R/健康显示，检查逐像素时序而非只内部合成分类口。先估native墙钟，必要长回归可冻结远端交用户投递；预计超过约120分钟的测试要报告实际启动后允许独立运行，不把未运行算PASS。本机不盲跑4小时旧整合整套。根据架构规模选择足够的最小端到端门，不能因快速省略新增流水线/后台仲裁关键风险。
一次fresh新工程综合/interface/place/route/basic normal I3 STA及内部未约束/精确CDC绑定。预算XLR<=51680（85%含routing）、RAM10<=204、DSP<=128；不重未改全FF/metadata/全时钟对资产审计。继承PLL异步SR未计时、外部7输入/135输出/窄hold/PVT暖复位限制必须披露。若真实新增约束风险则精确补查，不能泛化falsepath。
合格后只离线生成BIT，不运行Programmer/下载/SPI/写Flash。记录源/SDC/输入/产物实际sizeSHA与日志即可，不收旧1.65GB黄金包。

## 交付与停止
阶段回报架构/实际删除的调试资源/短测/资源/P&R/STA/BIT真实进度，给Work估时范围和阻断。普通内部Work核收自动接续，不等用户查询。新reports写PHASE_RESULT.json RUNNING/HEARTBEAT，最终DELIVERY_RESULT.json给v2阶段watcher；实际开发时更新通知context的近期Codex观察，不能由原生进程推断模型状态。
完成冻结未提交只读快照、实际源码闭包SHA、基本报告、已知限制、新BIT和CODEX_A_REVIEW_PROMPT.md，明确baseline和未提交状态。禁止Git写入/B调用/硬件；用户独立A不是内部Astra复核。Work核收后停用户A，A通过再用户实物，实物通过后精确Git+B补审。
