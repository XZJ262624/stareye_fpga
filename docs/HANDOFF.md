# 星眸项目交接单

## 1. 基本信息

- H-20261001-08，2026-10-01；任务：M0基础验收收尾、独立Git提交；提交后再只读视频参考核查。
- 仓库F:/Projects/stareye_fpga，main；PROJECT_BRIEF.md、STATUS.md、DECISIONS.md已读。
- L2，顺序委派GPT-6.1 Sol / Medium；同一时间单一写入者，主会话最终验收与提交。

## 2. 目标与边界

- M0基础验收通过：I3编译PASS，用户JTAG配置及流水灯功能定性PASS；断电启动来源未区分，不证明当前bit持久性。
- 保存用户摘录、验收边界、忽略规则与逐文件提交范围；代理不暂存/提交，主会话完成独立M0提交。
- M1实现未开始；视频资料仅在提交后定向只读核查。

## 3. 已验证基线

- 用户确认Ti60F225I3；Efinity2025.1.110.5.9；英文副本efinity/m0_led_i3。
- 官方综合/接口/P&R/bitstream PASS，内部setup +8.395ns、hold +0.092ns，56 XLR；复位释放及外部延迟覆盖边界保持。
- bit只读复核1,618,062字节，SHA256=46AC52D70DF7330864C7F2531361D9383E22475EDAC80FD3635EA2C2F43FF2B0；没有重编译或改动。
- 用户JTAG下载成功，Device ID 0x10660A79、Device is in user mode；LED从一侧至另一侧依次点亮熄灭，定性PASS。

## 4. 修改与提交范围

- 文档：.gitignore、README、docs的STATUS/HANDOFF/MILESTONES/MINIMAL_REFERENCE_CHECK/DECISIONS/PROJECT_BRIEF/TOOLCHAIN，SOURCES作为来源依赖；M0报告。
- 显式提交M0源码/配置、必要脚本与相关文本证据，清单见reports/m0_led_i3/COMMIT_SCOPE.md；逐文件字节清单在已忽略reports/git_baseline_inventory/m0_commit_scope.json。
- 不纳入document、AGENTS、原方案、tools、reference PDF、outflow/work、锁、缓存及bit/hex/lbf/vdb；不用git add .。

## 5. 验收标准

- 编译/JTAG/LED/断电启动来源分别记录，不虚构日志、LED号/8颗计数/往返/速度。
- 用户摘录不是原始导出日志；所选bit路径/下载文件哈希未独立核验。
- 本轮无SPI Active/Flash；断电流水灯与历史官方固化来源未区分，不证明本轮bit持久性。
- 提交清单按路径/字节数核查，忽略锁/生成缓存/bit，保留关键log/rpt；主会话最终提交。

## 6. 禁止事项

- 不新增业务RTL、不编译、不下载、不Flash、不安装；不改厂商资料或已验证顶层/时钟/管脚/源码配置。
- 不把定性LED报告扩展为全8颗、特定方向/速度或长期稳定性；不要求为了归档重复JTAG。
- 不提前读视频例程或进行M1实现。

## 7. 当前进度

- M0基础验收通过；文档、证据摘录及显式提交范围已核查，实际提交哈希以git log为准。
- 代理准备完成后停写交回；主会话复核后负责独立M0提交。

## 8. 待确认与后续

- LED编号/逐颗数量/速度、长期稳定性、当前bit持久性未验证，不阻塞本轮基础验收。
- 原始Programmer日志及下载路径/哈希未提供；不要求重测。
- 用户摄像头AR0135，具体接口/适配板/实际连接待确认，不由型号推断DVP；有HDMI显示器但缺HDMI连接线，待补齐。
- M0提交后只读核查AR0135与HDMI参考，优先评估HDMI彩条链路；视频参考仅候选，不外推兼容或冻结选择。
