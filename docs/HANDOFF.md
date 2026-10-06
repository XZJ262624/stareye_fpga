# 星眸项目交接单

## 1. 基本信息
H-20261004-M31；阶段M3.1；项目m31_sobel_controls；L3按AGENTS自动委派GPT-6 Astra/Medium，主会话最终独立复核。用户授权先提交M3基线，再创建独立分支和英文路径工程副本；本轮不自动提交M3.1。

## 2. 已验证基线
Ti60F225I3、Efinity2025.1.110.5.9；M2实物720p60实时相机→DDR→HDMI；M3离线通过，用户本轮实物二值Sobel/水平垂直斜边/动态更新通过，运行10分钟稳定、720p60、无黑屏花屏撕裂冻结错位重影。M3状态为“实物功能PASS、图像质量待调优”，见reports/m3_sobel_core_i3/HARDWARE_ACCEPTANCE.md。M3当前阈值64，静止场景动态白散斑、运动前后密度变化原因未确认。两张照片位于document/m3_pic，主会话已查看归档；照片不单独诊断动态现象原因。

## 3. 目标与架构门槛
先只读核实板载按键数量/管脚/极性/电压/复用、既有LED及像素域控制接口，提出三模式、阈值步长、可靠同步/消抖、当前值显示、帧内一致性和阈值64/96/128比较方案，经主会话放行后实现。优先使用已证实硬件，不猜按键管脚。曝光/增益/传感器噪声只核查，不改初始化。

## 4. 唯一写入权与范围
主会话先独占写入完成M3报告/精准暂存/提交；Astra第一阶段只读架构核查。收到主会话明确放行后才是唯一实现写入者，可写efinity/m31_sobel_controls_i3、rtl/tb/scripts的M3.1专用目录、reports/m31_sobel_controls_i3、必要docs/.gitignore/.gitattributes。禁止修改M2/M3原工程、M3五个核心RTL、document/reference/tools。子代理不做Git操作。

## 5. 验收
按键双触发器同步、稳定计时消抖、一次按压一次事件、长按/复位/组合键/同时事件行为明确；阈值8位、步长明确、0..255饱和不回绕，64/96/128可达；三模式可操作，当前模式和值可见或可可靠记录。仿真须覆盖抖动、短脉冲、释放、长按、边界、帧边界与模式/阈值生效时机、输出同步。完整官方I3接口生成/综合/P&R/bit，setup/hold/新增告警/资源/HDMI出口/新增CDC约束及最终DB/报告/bit哈希绑定；负向验收不可写死PASS。

## 6. 禁止与停止边界
不Programmer、JTAG、SPI Active或Flash，不碰板卡，不改相机/DDR/HDMI频率/既有管脚和参数，不改窗口/Sobel核，不加中值。新增按键接口仅按实际资料证据配置。离线完成暂停，不自动提交M3.1，不宣称M3.1上板通过。

## 7. 当前进度
主会话已读取PROJECT_BRIEF/STATUS/DECISIONS，已保存M3用户实测并完成独立提交。M3输入哈希未变，新增.lock是GUI临时锁，需精确排除验收输入盘点，不删除锁。委派第一阶段只读分析，尚未放行实现。

## 8. 交付与主会话复核
提交后由主会话提供确切M3基线hash，创建M3.1分支；Astra交付架构、按键/引脚证据、控制及比较方案、实现测试和构建结果、变更清单、风险和bit路径/大小/SHA。主会话独立核实原核不变、按键CDC/消抖/边界、同步和实际时序、Git范围，更新状态与交接。旧Flash风险不因M3实测关闭。

M3冻结基线：7a9b448080fd6f1624c2ef37ee2eb267fed49c82；M3.1分支：codex/m31-sobel-controls；已创建69文件精确工作副本。第一阶段Astra仍只读，未放行实现。

## 9. 架构放行（2026-10-04）
主会话独立查看核心板V1.4原理图第3、7页，确认K1=N2/CSI、K2=M2/CSO，Bank1A参考电压1.8V、10k上拉、按下接地；K3=CRESET_N不使用。实物V1.5与参考V1.4版本边界保留。官方配置模型说明CSI/CSO可兼作用户GPIO；仅在user mode操作按键，不改变配置模式。
批准Astra作为唯一写入者实施M3.1：像素域两级同步、20ms消抖、释放提交手势；K1阈值+16、K2-16、组合键切换RAW/MAG/BIN，饱和0..255，无长按连发，启动按住先释放。参数只在帧边界应用；OSD显示已生效模式和阈值，输出统一延迟一级。原五核及M2/M3工程保持不变。官方API配置新增按键及生成接口，定向约束第一同步级。完整仿真、负向验收、编译和最终证据绑定后主会话复核；禁止下载/Flash及M3.1自动提交。

## 10. 最终交接
2026-10-04：Astra/Medium完成控制/OSD/官方配置/编译及仿真初验，主会话接管唯一写入，修正端点误报、补脚本/dump绑定，实际执行94份隔离STA、最终仿真、1正向25负向及源码/1018文件复核。M3.1离线PASS、实物未验证；不自动提交/下载/Flash。M3冻结7a9b448080fd6f1624c2ef37ee2eb267fed49c82。完整交付与比较方案见reports/m31_sobel_controls_i3。纠正早期空闲GPIO假设：N2/M2原为旧LCD DE/clkout，新副本移除后改输入，其余接口未变。旧M3勿按K1/K2。当前暂停，下一步是按比较方案进行单独授权的实物验收；旧Flash风险保留。

## 2026-10-06 M3.2交付审查交接
用户指定GPT-6 Astra/Ultra审查交付包，主会话独立复核。M3基线7a9b448080fd6f1624c2ef37ee2eb267fed49c82；M3.1分支codex/m31-sobel-controls，用户确认已上板且阈值调节正常。交付ZIP已由主会话独立安全核查及哈希验证：79文件、75,382,662字节，77条CSV/78条SHA清单符合无自哈希规则，零错误；gzip为已识别文本证据，未执行交付脚本。解包仅handoff/review/m32_median_filter_delivery。
阶段一Astra仅静态只读审查RTL/TB/脚本与报告，禁止执行交付脚本、编译或修改原M2/M3/M3.1。主会话是唯一写入者，维护reports/m32_median_review和项目文档。静态通过后才放行独立测试；仅最终模块独立验收PASS后方可创建codex/m32-median-integration与efinity/m32_median_integration_i3副本。PASS WITH CONDITIONS/FAIL均不进入整机。集成写入权后续单独顺序移交，原工程永不覆盖。禁止Programmer/下载/Flash，禁止自动Git提交。


## M3.2 integration gate (2026-10-06)
ROOT standalone module verdict PASS, see reports/m32_median_review/MODULE_ACCEPTANCE.md and ROOT_MODULE_EVIDENCE.json. New branch codex/m32-median-integration, new input-only M31 copy efinity/m32_median_integration_i3 created. M31 working tree has not been committed; Git parent remains M3 7a9b448. M31 current XML functional canonical comparison with archived build XML is equal including all repeated IP nodes and schema-default ooc=false. Astra/Ultra is now sole integration writer. Allowed: new M32 engine/rtl/tb/scripts/reports, M32-specific ignore rules and necessary project docs. No changes to original M2/M3/M31, shared original cores/controls, vendor documents or tools. Fixed 1650-clock raster reanchoring, 1661-clock packet RAM delay, RAW preserved, 5x5-supported filtered MAG/BIN border, default bypass and separate enabled build mandatory. Independent sim/negative cases/full I3 build and final implementation timing hash binding required; no Git changes beyond ROOT-created branch, no Programmer/download/Flash.


## M3.2最终交接（2026-10-06）
独立模块PASS后创建codex/m32-median-integration及两个新工程副本。Astra/Ultra完成静态/架构/初版配置后，其续作代理触发限额；主会话接回唯一写入权，完成最终源码复核、独立整链路黄金、18帧小图/两个720p帧、旁路逐像素等价、两套完整I3编译、188份最终STA与17个CLI负向控制。模块、离线整链路均PASS；未实物验收、不承诺降噪改善。
最后修改仅新M32包装、顶层接入/参数配置、测试与报告、必要状态文档和定向忽略；原1,412文件内容/大小/mtime核验不变。RAM重锚1661拍、Sobel出口1666拍、OSD出口1667拍；同一原像素相对M3.1最终显示延迟1662拍。完整5x5支持域以外滤波MAG/BIN黑色，RAW全图原样；默认旁路参数0及独立参数1构建分别绑定bit/最终DB/STA哈希。
M31硬件新信息只确认阈值调节正常，旧Flash风险未关闭。用户下一步可审阅两配置与对比方案再另行授权JTAG验证；本轮不执行任何硬件操作，不自动提交。结果、位宽整改、统计口径、限制、完整拟提交文件清单及bit路径/大小/SHA见reports/m32_median_integration_i3；交付79文件清单在reports/m32_median_review/FILE_INVENTORY.csv。


## H-20261006-M31-M32 acceptance and ordered commits
User authorizes hardware acceptance archival and exactly ordered independent M31 then M32 commits on current development branch, no merge/push. First inspect real HEAD/index/file scopes and verify existing bit hashes without recompilation. Astra gpt-6-astra/ultra is delegated read-only review; ROOT sole writer and sole Git operator. Allowed writes: documentation, reviewed scope manifests and byte-preserving Git attributes; no RTL/clock/pins/IP changes. ROOT independently verifies dependency separation, source/DB/bit hashes, narrow hold/PVT wording, staged blobs and final commits. M31 shared RTL belongs only to first commit; M32 archive ZIP and generated artifacts excluded. Both commits exclude raw logs, caches, bit/wave/database, reference/tools. Generic shared docs/ignore are staged as reviewed M31-only snapshots first without overwriting current worktree, followed by final M32 versions. If scope cannot be reliably separated, stop before staging. No Programmer/download/Flash/power cycling/M4.


## 当前实物验收与停止边界（2026-10-06）
用户反馈详见reports/m32_median_integration_i3/ACCEPTANCE_REPORT.md；M32模块、离线、实物功能及本次运行条件稳定性均PASS。高阈值噪点差异小合理，低阈值中值收益明显且主要边缘保留；不扩展为全部图像质量或严格跨PVT证明。启用版+0.026 ns窄hold、PLL复位、旧Flash冷启动/R3/R4共享风险仍保留。M31共享控制/OSD依赖先入第一提交，M32两工程及本轮验收后入第二提交。仅归档和提交，不编译、不运行Programmer、不下载、Flash、重复断电或M4开发。

## 本轮归档限制
M3.1历史构建的原位置生成物存在25项缺失、6项变化，不能完整重放原验收器；保留审计副本bit/LPF/LBF及94份STA已独立匹配。详见../reports/m31_sobel_controls_i3/PRECOMMIT_EVIDENCE_CHECK.json。本轮不恢复或重编译。M3.2历史交付重放需本地handoff交付内容；最终整机源码闭包已纳入清单。

## 顺序提交记录（2026-10-06）
M3.1已独立提交：742d8a461b36f5970f7caea04fb8f8c925fe8a02，feat: add runtime Sobel controls and OSD，203个文件、7774280字节（提交涉及文件的最终blob总大小）。父提交为M3 7a9b448080fd6f1624c2ef37ee2eb267fed49c82。M3.2将以此为直接父提交，feat: integrate optional median filter；其自身ID以git log为准，避免在提交内容中循环写入自身哈希。当前分支codex/m32-median-integration；仅归档与顺序提交，不进入M4。
