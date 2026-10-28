# 回放＋简易圆/矩形识别合并版，2026-10-28

用户将正在进行的Canny回放任务调整为“能把这个回访功能和建议图像识别放到一起吗”；Work按回放＋简易图像识别（圆/矩形，不是计件）解释，已告知评估资源可行后连续快速实现，最终停用户独立Codex A。任务L3，当前同一Astra High为唯一技术Writer。先读docs/PROJECT_BRIEF.md、STATUS.md、DECISIONS.md及HANDOFF_CANNY_REPLAY_20261028.md，后者回放语义继续适用，由本文件覆盖最终交付对象。

## 身份与技术父保护

branch codex/m5c-fusion-prototype；HEAD433a83e543cb40a52128d1eea4ae32ce83aecd16，parentb5f36414035193ab9c7aa8393732a93e10fe141e，index空/未提交/无candidate，仍需核实际状态。计件open等待实物，不合入本任务。

识别技术父是已实物通过并归档b5f36414的扩大ROI工程：efinity/shape_wide_roi_i3、rtl/shape_wide_roi两文件、rtl/shape_standalone/shape/shape_stream_adapter_contract_v2.sv、gaussian_m5a等实际XML依赖。不能退回小ROI或改识别算法。用户圆/矩形各3次、旧框外新框内、空白/三角形UNKNOWN、5分钟正常的历史资格，仅作原识别父背景，不冒新合并版实物资格。

本轮未审回放父：reports/canny_replay_20261028/physical_20261028_175942，11186XLR/101RAM/0DSP，基本setup+.211/hold+.026；BIT2235528B SHA1cb7ecd8fb8ca4f563900c2a64597c4f556423440a41e65275a25d477334433c。32帧控制小几何及两历史帧720p/局部像素、故障/按键/守卫已有原生日志；首时序-0.668与修正源端点/失败数据库保留。无外部A/硬件资格，不把单独版BIT当合并版。正在进行的有用任务允许自然结束，停止单独版交付封装，不重复跑无关门。

## 允许/禁止范围

只新建rtl/shape_replay、tb/shape_replay、scripts/shape_replay、efinity/shape_replay_i3、reports/shape_replay_20261028。旧wideROI/Canny/计件及本轮canny_replay技术父目录保持，初始必要生产文件逐项SHA保护。依赖需改复制新命名，禁止混入两套同名模块；可按明确固定清单读取不变硬IP。Work拥有docs。禁止Git写/清理/提交/B/Programmer/下载/SPI/Flash，禁止改时钟、管脚、镜像、720p。

## 冻结功能与帧语义

1. 同一BIT提供LIVE实时画面＋圆/矩形/UNKNOWN识别，REC录约2.1秒32完整720p灰度帧，自动PLAY循环；PAUSE/继续、回LIVE、已有clip重播、取消/重录按回放父语义保留。新录开始立即撤旧clip；中断后不得播放部分覆盖旧片。DDR地址、每4camera抽样/每4完整display重复、真实B+EOF登记、读lease/合法camera排空、故障hardstop保持。
2. PLAY和PAUSE输出历史灰度，经过同一GAU/local Canny＋原wideROI识别重新运算；不是回放时偷用当前相机的分类，也不是存几个标签假装图像回放。PAUSE重复历史capture ID是合法显示，独立displayseq仍递增；保留每帧完整性、epoch/config和像素tag关联。不要新增历史帧年龄门让合法回放反复UNKNOWN，也不要移除实际完整性检查。
3. 保持960×540 ROI、四侧16px内余量、原80..440目标尺寸/原形状规则、H64/L32、GAU2、圆/轴对齐矩形/空白及三角形UNKNOWN。单目标、无新增抗条纹/旋转能力。识别结果沿原PREV语义说明一显示帧延后，不把旧结果冒当前画面；LIVE↔PLAY或新clip会话切换应防旧上下文标签污染，必要配置/会话tag做最小接入，不复位DDR或强清在途队列。REC与LIVE同实际相机源可同上下文，PLAY/PAUSE同clip上下文。
4. 优先三视图RAW/CNY/COV，默认COV便于识别演示；沿用原识别流mode0/5/6语义，不能把split五模式mode2直接当原CNY。参数固定H64/L32以简化两键，不要求另加阈值调节；最终操作说明明确按键已用于回放。K1短录制/暂停继续，K1长返回LIVE；K2短切视图，K2长重播已有clip为建议。若跨域视图为多位，需原子稳定传递并在帧边界生效，不能多位各自两级同步冒原子包。长短按/双键抑制/启动释放保护保持。
5. 屏幕清楚显示LIVE/REC进度/PLAY帧号/PAUSE、视图/绿色框、PREV分类，标签不互遮、不入ROI影响观看。实际错误与无clip明确，不新增整图RAM存OSD；两个OSD合并尽量不增加视频延迟，若加拍务必全packet同步并测试。

## 必要自检、物理与停止

首选复用回放父已测未变字节与原识别数学/行表，补合并接入测试：实际摄像灰度→DDR→历史读→GAU/local Canny→adapter→recognizer→OSD。至少完整720p的圆/矩形/空白或三角形轮换，PLAY来自真正DDR存储；检查历史分类而非当前相机分类，暂停重复captureid仍可识别、displayseq递增，循环首尾/回LIVE/取消重录/上下文撤旧。原识别边界向量在新拷贝精确复用，不能更改期望判据宣称通过。可小几何做更多控制故障，但分类真实几何不能伪缩比例冒生产ROI。

只对受影响控制/位宽/多位CDC/OSD对齐补定向门，不自动重跑全部历史全局BFS或旧72帧。原已完成回放门可凭明确原字节复用，不重复无关长门。新fresh综合/P&R/basicSTA、资源<=204RAM及实际逻辑预算，精确CDC实际Q/门/目的D和两时钟绑定；Gray最高位别名保持同5ns/hold语义，禁止扩大falsepath。来源与最终生产/DB/BIT绑定，失败证据保留。

长阶段v2watcher用本次新最终收据/StatePath，实际PID状态核验，不重放旧结果。Work持续内部复核，普通待Work不停用户；>120min单门先说明。交付最小冻结快照逐文件大小SHA、实际BIT、必要测试/构建摘要、CODEX_A_REVIEW_PROMPT.md及完整操作说明。明确合并新未提交快照身份，停止Writer后交Work核对并停用户外部A；不内部模拟A、不提前硬件放行、不Git/B。


时长口径补充：32个采样周期名义约2.1248秒；第一幅到第32幅时间戳间隔为31个间隔约2.0584秒，按键至完成另含边界等待。用户说明用“约2.1秒短片”，不保证按键墙钟精确时长。完整播放循环32×4/60≈2.133秒，实际帧率待实物。
