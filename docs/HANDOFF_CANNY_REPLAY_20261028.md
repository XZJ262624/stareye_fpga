# Canny基础独立回放演示版，2026-10-28

用户授权：做可演示回放功能的BIT，不基于计件，基于以前Canny工程，快速流程。任务L3（DDR/视频/CDC），GPT-6 Astra High唯一技术Writer；Work负责文档与最终核验。当前branch codex/m5c-fusion-prototype，HEAD 433a83e543cb40a52128d1eea4ae32ce83aecd16，parent b5f36414035193ab9c7aa8393732a93e10fe141e；未提交、无candidate、index空。先只读核实际身份。

先读docs/PROJECT_BRIEF.md、STATUS.md、DECISIONS.md、AI_WORKFLOW.md、REVIEW_PROTOCOL.md。旧计件open版在独立A PASS后等待用户实物，不能写成已通过，不修改其任何目录。之前Canny split_thresholds已实物用过、镜像3040/C000修正需继承。

## 独占允许范围

只新建rtl/canny_replay、tb/canny_replay、scripts/canny_replay、efinity/canny_replay_i3、reports/canny_replay_20261028。需改父模块复制新名/隔离工程，旧工程/源码/冻结包/失败证据全部保护。Work单独拥有docs；不修改根共享源码/约束/工具。允许只读继承未变硬IP/已有已验证依赖但须锁定生产清单与SHA。禁止Git写、清理、提交、B、Programmer、下载、SPI/Flash、改管脚/时钟/720p与镜像。

## 目标与方案收敛

必须是真正多帧短片DDR记录→历史帧按顺序重复回放，拍视频能看到刚才动作重现，不能用单帧冻结或四slot最近帧冒充回放。优先专用LIVE/REC/PLAY/PAUSE演示工程，继承旧Canny相机/DDR/HDMI与局部Canny滤波；不要求搬入计件或低频全局BFS/融合，避免无关资源与DDR冲突。显示RAW和局部Canny边缘可切换，说明这是专用回放版而非全部五模式新资格。

先快速核真实DDR物理容量、地址单位、控制器/守卫允许区间、旧实时slot和后台区；给Work明确技术方案及录制帧数/抽帧频率/时长/内存布局/控制映射/资源估计，Work自动核GO后连续实施，不让用户转交。目标可参考32完整720p灰度帧、约15fps采样（约2秒）并按相同节奏回放；这是偏好而非必须先实现的固定数。必须依据实际容量/带宽确定可行值，未经证据不宣称多秒录像。若需要降低空间分辨率或少于约1秒，应先给Work技术理由，不静默用冻结替代。

建议按键简单：一键主流程（LIVE开始录制；录满自动PLAY；PLAY暂停；PAUSE继续），另一键RAW/CNY，双短回LIVE保留片段，重录明确失效旧clip；需从LIVE再次回放已有clip的明确入口。具体键长短可在方案阶段优化，保留去抖/仲裁，UI直观显示LIVE/REC进度/PLAY帧号/PAUSE。只在帧边界改变读源/帧号；暂停仍重复完整同一历史帧，不能停止HDMI同步；LIVE恢复无撕裂、无旧FIFO尾混入。

## 核心要求与必要验证

录制帧只在完整camera帧+真实DDR写响应全部完成后登记；clip完成前不可播放半帧，循环/暂停/恢复不能读写同slot冲突。DDR真实AXI响应/ID/RLAST/FIFO/CDC/冷hard-stop保护保留，不伪造B/末R/resetACK，不用延迟掩盖缺帧。相机即使在PLAY继续出流，也必须明确如何合法丢弃/接收、避免FIFO溢出及EOF邮箱堆积。改变历史身份语义须明确区分capture_seq/display_seq，不让原仅允许新帧资格错误拒绝重复回放；不得删除实际帧完整性检查。SOF/CE/packet对齐、滤波warmup/模式切换、取消/重录/空clip请求、连续操作/按键bounce、stalls和DDR错误需针对性覆盖。

测试应包含带唯一帧号与像素pattern的真实DDR事务行为模型，逐像素验证记录顺序、回放顺序/循环、暂停重复、继续、返回LIVE、重录、最后一帧/首尾像素；至少少量完整720p集成验证关键边界，短几何可用于更多控制/错误组合但必须披露。容量/地址alias证明、实际请求/响应/EOF登记的独立断言必须有。没有必要重跑所有历史全局Canny长回归。若一个计划单门超过约120分钟先报告Work。

新fresh综合/P&R/basicSTA，按实际变化补DDR/CDC专项而非盲复用旧约束；不可放宽false-path换PASS。保持板204 RAM预算与实际逻辑预算，保留外部IO/PLL/PVT/暖复位等继承边界。锁最终生产输入、物理镜像/必要DB、原生与交付BIT大小SHA，核最终日志确来自最终源码。失败原件保留。

长阶段用scripts/work_notifications/start_watch_v2.ps1独立StatePath和该次FINAL_RESULT，记PID/命令/创建时间及阶段名；只整组弹窗，不每短例，不播放旧结果。无聊天自动唤醒保证。阶段进度持续发Work，不在普通待Work结束当前工作。

## 交付与停止

Writer完成源码/定向测试/新BIT/basicSTA和最小冻结快照（逐文件大小SHA、明确未提交身份）后交Work，附完整CODEX_A_REVIEW_PROMPT.md、操作说明、结果/限制、真实控制映射/时长FPS、资源STA/BIT信息。Work核对后停用户外部A；不得内部模拟A，不硬件操作，不审查前Git或发送B。未来独立A通过后Work才单独给用户硬件清单。


## Work已核内部GO：2026-10-28

32完整720p×8bit帧，29,491,200B有效payload；clip index0..31，base0x02000000、stride0x00100000，最终exclusive0x03FE1000。每4camera抽1，按配置名义60.24096fps约2.1248秒窗口；HDMI60Hz每完整历史帧消费4次前进，循环约2.133秒。实际帧率/新clip地址物理资格未测。理论512MiB配置不是全容量实测，加密内核内部映射未重算；旧地址诊断仅有限点证据。

K1短：LIVE启动REC；PLAY暂停；PAUSE继续。32帧完成自动PLAY。K1长：回LIVE/取消REC。K2短：RAW/CNY。K2长：LIVE对已完成clip从头PLAY；无clip无效。开始REC立即撤旧clip有效性；中断REC无合法旧clip，只有重新录满32帧才有效。PLAY/PAUSE区域不写，相机持续live四slot合法排空。具体同步命令/按钮组合不得让一个长按额外触发短按。

详见WORK_CANNY_REPLAY_ARCHITECTURE_GO_20261028.json和WORK_CANNY_REPLAY_ACCEPTANCE_PLAN_20261028.md。下一阶段已授权实施，不再等用户确认方案。
