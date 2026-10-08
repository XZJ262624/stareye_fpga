# M5B.0R Codex A FAIL修复

本轮是Codex exec开发与验证，不是独立审查结论。新candidate直接以 `6c44df8c5edc10c45a59c4c867e3fc44a6e7456d` 为parent；branch为 `codex/m5b0r-ddr-admission`。candidate自身ID由提交后Git读取。本轮保持NO_GO，等待Work验收及独立双审查。

## 修改与验收依据

- 仲裁器在 `ddr_reset_ack` 高电平期间禁止地址READY；状态机ACK清理不再吞掉外部已观察到的握手。TB在ACK记账清理分支之前独立断言READY为零，保持三个VALID跨四个ACK时钟，撤销后等待恰好三个事务完成，并核对accepted=completed+cancelled。原九个复位/响应异常场景和随机背压继续运行。
- 诊断TB从冻结规格构建独立的9967条有序总线计划，逐事务检查地址、读写、长度，逐写拍检查模式及walking位，完全不引用DUT内部phase/mode/point/计数作为预期。健康、提前B响应及重新复位三类流程均执行此检查。
- 独立计划复算：alias 4×38=152事务；范围6×462×2=5544事务；walking 2×128×8×2=4096事务；守卫7×25=175事务，总9967。写拍=(38+25)+6×462×128+2048=356927；读拍=(38+13+38)+6×462×128+2048+175=357128。每次完整PASS必须命中这些固定数量，提前PASS不能靠RTL/TB共同漏计通过。
- 保留54例诊断的含义（含FAULT=27总体超时），新增阶段/模式负向测试归于独立负向验收，不混入54例数。负向共9项：原诊断比较器/仲裁ID/LED载荷/软件比较器4项，以及恢复旧ACK漏洞、跳过walking、跳过首守卫、缩短范围、模式4替换5这5项。每项实际运行隔离RTL突变，要求指定Fatal且真正项目Python验收器非零退出。

## 构建与证据边界

本轮改动的仲裁器是未接入诊断顶层的隔离原型。诊断RTL、DDR IP、工程XML/SDC/peri、顶层/管脚/时钟均未改变，因此复用既有完整I3构建与112份STA，不重新综合或P&R。最终验收器重新核验全部13项输入、53项实现输出、112份STA、最终STA绑定及bit哈希。原setup/hold最小+0.100/+0.021ns，7391 XLR/30 RAM10/0 DSP；这些数值不代表新增仲裁器已综合或通过STA。

bit路径 `efinity/m5b0r_ddr_address_diag_i3/outflow/M5B0R_DdrDiag.bit`，2157846字节，SHA-256 `249b4b5e4095da1e7466f94d510c17de4588161c37de484a0eff427304cef3f3`。仅本地保存并被Git忽略。

## 复验方式与归档

提交前：`m5b0r_evidence_verify.py --parent 6c44df8c5edc10c45a59c4c867e3fc44a6e7456d`。提交后：`m5b0r_evidence_verify.py --candidate <完整新candidate> --parent 6c44df8c5edc10c45a59c4c867e3fc44a6e7456d`。后者校验精确HEAD、唯一parent、空索引、干净跟踪工作区、清单中每项候选blob与本地证据相等；两种模式均复核实际证据。原始仿真日志/实现数据库仍需本地保留，Git快照本身不含这些排除物，不能称纯克隆即可完整重放。

PROPOSED_GIT_SCOPE记录本阶段完整candidate载荷（沿用文件+新增/更新文件），增量commit差异由Git给出。原CANDIDATE_ARCHIVE和ROOT_REVIEW保留为旧candidate/旧离线历史，不覆盖本轮结果。Work已写入的双审查长期授权与Codex A FAIL归档纳入本次candidate；不得把修复验证当成Codex A复审PASS。

真实高地址/校准保留区、真实DDR仲裁epoch取消桥接、服务上界、FIFO/CDC/720p60共存、实物LED、PVT仍未验证；M5B.1不放行。本轮未运行Programmer、下载、SPI Active、Flash或任何板卡操作。
