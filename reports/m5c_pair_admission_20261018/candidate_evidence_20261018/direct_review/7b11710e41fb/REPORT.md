# 入帧失败：有界因果诊断交接

固定candidate `3c693037b79b4129856a2c43f2bcfe54ce18d623`。只新增本报告目录；canonical RTL/SDC/TB/bit、原实物文件均未改，没有新完整视频/I3/Git写入/硬件操作。

## 实际结果与证据等级

ModelSim10.1c实际编译/执行：第一批20个case、session_hold探索2个、完整预绑定session_hold_v2两例、session_hold_v3一例均exit0且唯一相应PASS marker，无Fatal/timeout。原始命令/PID/启动时刻/elapsed/退出见各OWNER/RESULT，工具SHA见TOOLS。所有本轮native已退出。

第一批与session_hold探索批执行前只绑定core快照，**没有TB/runner预执行hash**，故仅探索日志，不事后补造prehash，也不称正式全闭包资格。v2/v3执行前PRE_NATIVE_BINDINGS绑定TB/runner/12core原件+快照与工具，POST逐项不变，作为可审核有限因果证据。默认sandbox首次vlib创建失败WinError623，未运行native；窄范围提升后成功。没有修改系统策略或工具。

## 第一批：同一reason2的不同机制

真实fusion_display/age_guard/row_fusion、offer mailbox、pair_controller select→ACK→arm、capture arm mailbox实例。外部offer/lease ACK为明确模型，没有完整backend/DDR。capture几何40×40，final_de=0，只验证入帧，不是采满帧；UI100MHz/PIX约74.627MHz，与生产96/74.4不同。bitmap bit8..0分别是 admit、mode_cov、fusion_enabled、!kill、identity_ok、eligible、source_qualified、session==armSID、display_seq==armSID，读取真实端口用于观测，断言检查实际state/reason，不拿bitmap拷贝充当被测逻辑。

- case0及时路径：UI select385ns、ACK395ns、arm405ns，PIX armvisible449ns；首tap503ns bitmap111111111，真实进入CAPTURE。
- case1–6近首tap相位：case4 armvisible与首tap同一PIX沿时capture还在IDLE，只在该沿转WAIT，错过目标首tap；下一display seq2与armSID1不等，reason2。case5下一拍首tap进入CAPTURE。同拍存在一拍IDLE→WAIT语义，不应无依据称mailbox丢数据。
- case7先目标首tap再arm，下一SOF fullSID拒绝；case14相同低32但高32不同同样拒绝。
- case8/9分别实际产生120/121个SOF：120合法、121拒绝。case15/16/17分别在首tap年龄148499999/148500000/148500001：前两入帧、后一拒绝；这三例显式设置age.pixel_ticks初态，**不是实际等待148M拍**，不改常量/eligible。
- case10 prefill0、case11 raw sourcequalified0、case12 config变、case13 epoch变，均实际reason2，说明仅凭reason2不能反推出单一原因。
- case18 offer首次可见与首tap同沿、case19 offer在首tap之后，fusion_display原门拒绝，capture reason2。保持了原“本沿首次tap已晚”的规则。

## 真实session排队复现（关键）

session_hold_v2/v3接入实际 m5c_display_session，包括内部224bit request mailbox、offer/control/active tuple路径、mask_reader/cache实例；另实例化实际64bit pair_request mailbox和实际pair controller/capture/fusion_display。UI约96MHz、PIX约74.4MHz（1ps精度下半周期5.208ns/6.720ns）。每个SOF间距为短控制刺激，不是完整720p。telemetry_pending跨SOF保持是**外部环境模型**；lease ACK为一周期模型；DDR aready/rvalid置0，停止在入帧结果前，不作reader/prefill/lease恢复资格。selected_witness只含实际acquire+fullSID匹配，不冒称完整backend的所有选择保护均运行。

实际session源码IDLE仅在 `req_valid&&!telemetry_pending` 时消费；pending期间request_box保存最早SID1，不能被后续请求覆盖。解除pending后真实acquire仍使用该旧SID。

- v2 case0及时：实际session active1/currentPIX1，offer接受，capture进入，reason0。
- v2 case1：pending跨11个后续SOF，解除时currentPIX12；新result source_seq11。acquire active1/pair_req1，offer旧SID1被拒late1，capture reason2。这例有reference source_seq11>oldtarget1的人工关系，仅作探索机制，不据它匹配硬件。
- **v3 case2修正上述边界**：reference source_seq0/tick0在排队前，oldtarget1（source+1）；pending跨11帧，currentPIX12。真实记录：
  - t3828ns：actual request1→active1、pair_req1，currentPIX12，selected_witness1。
  - t3838ns ACK，3849ns arm；3891ns PIX armvisible。
  - t3904ns actual offerSID1/current12，have_offer0、late1。
  - t3958ns WAIT首tap bitmap011110100，age12帧/287ticks，仍reason2。
  - 该参考不是未来数据，未超过TTL，失败源于旧请求SID/offer与当前显示帧错位导致admit/eligible及SID门拒绝。

这是一个可达环境条件下的真实组件复现，支持“pending保留旧request→发布后acquire旧SID→诊断消耗机会但PIX合法拒绝”的解释；不等于已观测到第二轮硬件八次的完整内部沿。真实type4producer/后台ENGINE状态与服务负载未在这两个短case重放，不能把pending持续时间当实测硬件波形。

硬件已知：首次SID2499帧末age273/339071616明确过期；Work独立相同job匹配显示后7个reference随后在age11–18帧有效，故不能全归因TTL/算法慢。上述排队机制与后7目标到最早有效reference相隔10–17帧相容，仍是受证据支持的候选因果，不作唯一确认。

## 最小下一方案比较（未实施）

**优先建议：pair诊断请求独立追踪最新完整SID；不改production display、TTL、capture守卫或线协议。**

1. 当前pair_request mailbox被hold/业务条件延迟消费。UI端改为对每个已到达valid消息及时take，保存最新64bit SID及valid；不要求所有源SOF都被邮箱保存，仍遵循busy/ACK协议。
2. 选择用 `effective_latest_valid = mailbox_valid || latest_valid`、`effective_latest_sid = mailbox_valid ? mailbox_data : latest_sid`，与实际fusion_acquire的完整session比较。新消息与acquire同拍时优先真实有效新消息，不读旧寄存器值放行。复位清valid，不能用初始SID0当有效；不截高32位，不引入无证据跨reset身份复用。
3. 旧acquire与latest不符时，正常display acquire/ACK/offer/release保持原行为；仅不pair_selected，因此不清fresh_publication_seen、不增attempt、不arm。正常session自行拒旧offer并恢复，之后当前SID仍能选择尚未消耗的fresh publication。
4. 继续保留完整descriptor/config、全部writer/packet/engine/arm/lease保护。8attempts定义仍是实际pair_selected尝试；不让已selected后失败无限重试，不修改terminal。最新SID寄存器不证明PIX此刻帧号，CDC尚未送达的近SOF几个拍仍可能失败，原完整PIX守卫不可删除。
5. 需新冻结后验证：真实双mailbox+backend，旧请求跨多SOF后staleacquire不耗fresh/attempt；下一当前SID同一pub成功选择；新valid与acquire同拍、旧valid、无valid、reset、同low32高位不同、sourcebusy丢中间SOF、停止/拒绝/后续恢复；协议和payload字节不变。完整视频/物理/双审/实物后续按新源重新绑定，不能拿本报告直接换bit。

这比先增加采集协议更小，可针对已复现机制改善机会分配；不保证修复所有硬件reason2。保守资源估计新增UI latestSID64+valid以及相等选择组合，实际可能复用原requestdata存储，**未经map不能声称零成本或fit**。

**备选：纯被动失败观测**，仅在最小调度验证仍不能定位时考虑。记录首个WAIT失败的9位原始谓词、armSID/current session/display_seq全64、PIX arm可见tick/失败tick、实际age及valid标志；保持原reason2及排空。若上UART，必须新明确schema版本（例如type10 schema3仍256B，显式定义新增区并保留schema2 decoder严格零规则），绝不偷用旧schema2 reserved。跨域须原子held/mailbox，不能给显示/lease加背压；若最终采用再冻结完整字节表、资源/CDC/非干扰测试，当前没有实现或授权硬件。

当前建议Work核定第一方案后继续隔离修复验证，不要求用户再次盲录。所有源/原件/安全门保持，本报告不发布新candidate或硬件资格。
