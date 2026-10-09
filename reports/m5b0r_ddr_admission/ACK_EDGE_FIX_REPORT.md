# M5B.0R ACK边沿追加修复（Codex exec开发验证）

本轮固定父提交为 `02841e20e297e4e6fdd14db0762a91d7089232fb`，分支为 `codex/m5b0r-ddr-admission`。新candidate自身ID由提交后Git读取。本报告是开发验证，不是Codex A或DeepSeek B独立审查。M5B.0R/M5B.1继续NO_GO。

## RTL协议与定向证据

真实 `ddr_reset_ack` 表示DDR及客户端旧epoch均已取消。在ACK为高的同拍，A/W VALID、B/R READY均组合屏蔽；同时客户端地址/写数据READY、B/R VALID均屏蔽，防止任何一侧观察到将被ACK优先清账的握手。ACK撤销后状态为IDLE。该条件不包含普通soft_reset；soft_reset只隔离新请求并继续保持/排空已开始的A/W，因此既有stalled VALID语义不变。外部仍必须保证ACK真实且在本时钟域安全使用，本轮没有实现生产CDC或实际DDR复位桥。

TB在ACK清账之前独立检查四个DDR通道握手和客户端数据接口暴露。新增四个定向场景实际进入A/W/B/R状态，在对应peer READY/VALID有效时拉高ACK，检查旧状态及激励确实存在，记录四位覆盖1111；之后检查accepted=completed+cancelled。A状态的aready明确强制为1，不能再靠ACK分支清账跳过观察。原持续四拍客户端ACK重叠/恢复、九个soft_reset/背压/响应异常场景全部保留。

五个既有仲裁种子与独立种子20261009均通过；五个常规种子各完成20500笔，独立种子实际accepted 20516、completed 20501、cancelled 15，新增四个取消边界全部覆盖。54例诊断及monitor全量重跑通过。13项真实负向全部拒绝，包含原九项及分别移除A/W/B/R ACK屏蔽的四个突变；每项要求指定Fatal，并用项目实际fail-closed Python验收器再次运行取得非零退出。ModelSim自身可返回0，不能据此判负向通过。

## Candidate范围验收

`m5b0r_evidence_verify.py --candidate`的实际Git门核对parent→candidate全部实际改动路径属于manifest白名单（包括manifest自身）。使用NUL分隔及`--no-renames`，重命名源和目标均须允许。新增/修改文件必须与candidate blob逐字一致；删除必须在独立deleted_paths显式列出，并与实际删除集合相等，工作区也不得残留该路径。本candidate没有删除。原精确HEAD、唯一parent、空索引、跟踪工作区干净及blob一致性检查全部保留。

`m5b0r_scope_negative.py`在隔离的真实Git仓库创建固定parent/candidate，通过子进程直接调用生产验收器使用的同一个candidate Git门。允许新增/删除/重命名三例通过；scope外额外提交、删除、重命名源及重命名目标四例均因实际差异超scope被拒绝。未模拟Git输出，也未改变主仓库历史。结果和日志哈希见root_review/SCOPE_GIT_RESULTS.json；隔离仓库和日志本地保留，不纳入candidate。

## 构建复用、保护与边界

诊断工程13项构建输入未改变，仲裁器未接入诊断顶层。本轮重新核对完整证据绑定，复用原53项实现输出、112份STA和bit，不重新综合/P&R。setup/hold最小+0.100/+0.021ns，7391 XLR/30 RAM10/0 DSP仅属于诊断工程，仲裁器仍未综合/STA。

bit为 `efinity/m5b0r_ddr_address_diag_i3/outflow/M5B0R_DdrDiag.bit`，2157846字节，SHA-256 `249b4b5e4095da1e7466f94d510c17de4588161c37de484a0eff427304cef3f3`；本地忽略，不提交。ACK_EDGE_PROTECTION_CHECK.json记录10469个旧文件哈希/大小/mtime及完整集合复核，1550个历史未跟踪路径保持。没有硬件操作、生产视频接入或DDR实物安全容量证明。

复验：先运行m5b0r_scope.py --verify；提交前证据使用 `m5b0r_evidence_verify.py --parent 02841e20e297e4e6fdd14db0762a91d7089232fb`；提交后增加 `--candidate <完整新candidate>`。完整证据校验需要本地原始日志/实现数据库，纯Git快照不包含这些排除物。修复提交后立即停止写入，由Work复核并交独立双审查。
