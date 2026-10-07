# 快照、收敛、缓冲所有权与CDC契约

本文件是未来实现的规范；protocol_model.py有34条功能契约测试，未进行RTL或CDC时序验证。初期global控制与引擎都用96MHz DDR UI域，避免额外处理时钟域；M5A分类在74.4MHz像素域，相机仍有独立cmos_pclk，显示/未来融合在像素域。

|缓冲|状态/所有权|唯一写者|允许读者|释放条件|
|---|---|---|---|---|
|视频0～3|现有管理器；本轮整体保留|现有相机DMA|现有显示DMA|由旧管理器决定，M5B不得自行借用|
|快照A/B|FREE→ARMED→CAPTURE→DRAIN→FROZEN→PROCESS→FREE|持有capture token的快照DMA|FROZEN之后的global引擎|job结束且所有相关R/B已完成；非法帧先排空再FREE|
|工作A/B|INIT→READ/WRITE方向角色→SWAP→…→CONVERGED/INVALID|global引擎|global引擎；结果复制器在收敛后|同job独占；每方向全部W/B完成后交换；不得被display读|
|结果A/B|FREE→COPY→PENDING_READY→LEASED→FREE|结果复制器|已ack相同descriptor的display/M5C reader|最后一次读突发及R响应完成后release ack；pending亦占用slot|
|元数据页|控制域权威寄存器+可选DDR镜像|UI控制器|经完整descriptor mailbox的消费者|版本/epoch检查；不是跨域裸读DDR字拼成descriptor|
|QUARANTINE|复位/错误仍有在途AXI|原事务owner只允许排空|禁止新reader|旧R/B排空并重置同步握手后才重新授予|

状态机：IDLE接受request且分配FREE快照→ARMED等待下一个完整分类SOF→CAPTURE按固定坐标打包→DRAIN等待最后有效像素、FIFO清空、全部B响应正常→FROZEN descriptor提交→INIT C0=S→FORWARD→FENCE→REVERSE→FENCE→CHECK_PAIR。若changed=1且未超时，继续下一PAIR；changed=0进入CONVERGED→COPY_RESULT→FENCE→PUBLISH_PENDING→IDLE。任意帧错/11/越界/响应错→ABORT/DRAIN/INVALID；超时同样不经过PUBLISH。

busy时新请求返回拒绝并递增dropped_requests，不修改当前frame_id，不覆盖FREE以外快照。ARMED不接受第二请求；请求触发点晚于SOF则等待下一帧，不从中途捕获。一秒请求频率只表示最多请求率，不保证输出率。初版禁止同时处理和捕获下一job；A/B仍有明确所有权，为以后流水保留。

|信号|产生→接收/含义|
|---|---|
|snapshot_request|UI→像素域token握手，含buffer_id与epoch，不是可能漏掉的单周期裸脉冲|
|snapshot_armed|像素→UI请求已接收，等待完整分类SOF|
|snapshot_frame_start|像素域首帧边界事件，锁存snapshot_frame_id/config/geometry/epoch|
|snapshot_frame_done|UI域所有921600像素且最后写B响应完成、身份/格式正确后提交；不是最后W拍|
|snapshot_buffer_id/snapshot_frame_id|冻结descriptor所有权与64bit回放帧号|
|global_busy/global_iteration|UI寄存状态，iteration为双向pair计数；另scan_index明确方向|
|global_changed|本PAIR所有有效像素`new & ~old`的OR，两个方向OR；跨burst/流水stage持有sticky位|
|global_converged|只有完整PAIR零变化且所有R/W/B/管线归约完成后置1|
|global_timeout|wall/iteration/no-progress任一watchdog触发，带reason；失败job不得result_ready|
|global_result_ready|描述符PENDING_READY toggle/mailbox，消费者ack后才允许复用mailbox|
|global_result_buffer_id/frame_id|与结果payload同一个descriptor锁定，不单独双触发器同步多bit|
|global_result_age|消费者以同epoch当前回放frame_id减源frame_id，按帧计；epoch不同/负差置age_valid=0|

frame_id使用64bit不回绕递增；epoch使用64bit会话代次。frame_id即将溢出必须停发新任务并完成全域epoch重建，不把模减当作正常age。对外age32bit饱和，另有age_valid；不是用低频结果序号相减，也不是仅以迭代耗时换算。阈值H/L、median_enable、mode、NMS规则版本、support_radius、几何、源SOF时间戳与frame_id都属于不可变descriptor。显示模式改变也记录，虽然它不改变分类谓词。

像素入口以真正进入NMS分类packet的数据字段为准，验证SOF一次、720行、每行1280像素、坐标连续、EOF一次、强弱互斥、配置整帧不变、raster_fault=0。打包完整W×H（算法边界00），frame_id和epoch随每个FIFO记录/帧tag校验。只计921600个pixel而不校验行结构不足以发现混帧或错位。任一异常不阻塞M5A实时通路；丢弃本次快照、记录原因、排空已发事务。快照overflow也只使该任务失效，不能hold住实时DE。

CDC规范：稳定电平控制（busy、error摘要）可双触发器同步；事件采用toggle req/ack或异步FIFO。多bit descriptor在发送端保持不变直到ack，先同步toggle，接收端在稳定窗口采样整descriptor并应答，后端寄存后消费；加入epoch/generation防止旧ack误释放。descriptor不可逐bit独立两级同步。像素payload使用标准Gray-pointer异步FIFO，双域reset握手；约束Gray bus skew/max-delay、同步器属性及目的域释放，不用笼统false_path当作CDC正确性证明。

像素→UI的完整descriptor提交必须在payload所有写B响应成功之后；在此之前只有capture owner可写。UI→display的ready描述符保持稳定，消费者仅在本地SOF一次性锁存，当前帧内buffer指针固定。结果reader释放旧lease需保证其全部读响应已经收完；仅收到下一SOF不足以证明DDR读已结束。两结果都leased或一个leased+一个pending时，global在COPY/PUBLISH前等待/安全丢弃未发布job；绝不覆盖旧结果。PENDING与CONVERGED等待也受wall资源占用watchdog约束。

changed具体实现：每有效输出pixel计算`new ^ old`（已证明单调时等同new&~old），每beat OR，整个扫描sticky OR；正反结果再OR。只有end-of-frame token穿过最后归约寄存器，所有应有pixel/burst计数匹配，读响应无错，最后写响应完成，才冻结该扫描changed。末拍变化不能被同拍clear丢掉。START_SCAN清零只在上轮状态已锁存并确认所有管线空时执行。epoch不符、位数/长度/地址检查失败直接abort，不能“没有changed”而误判收敛。

迭代上限建议64双向轮，wall上限1s（96,000,000 UI时钟）；无进展watchdog按后续仲裁最大延迟契约推导，不能现在随意编造一个足够值。若ready写栅栏与timeout同拍，优先错误/timeout，除非先前周期已经原子发布完成。converged=1只说明传播数学完成，仍必须通过最终复制/所有B及descriptor fence后ready。超时保留上一份有效结果并增加age，或标记无结果；timeout属于失败job，不能给旧结果的frame_id错误归因。诊断可保留未收敛工作DDR内容，valid始终0，不能用于显示/融合。

PLL失锁、DDR cal_done撤销或cal_pass失败：异步拉低新业务valid、停止授予、各域同步释放复位，原在途地址owner保留到drain/控制器重置确认。即使UI时钟停摆不能计wall watchdog，也由独立失锁/复位路径阻止ready并使所有lease失效。恢复前全域flush ACK、FIFO empty/reset_done、DDR重新cal_done&cal_pass、PLL稳定、epoch交换全部成立；等新的完整SOF重新开始，旧DDR内容一律无效。warm reset增epoch；cold reset即便counter重零也先跨域清空所有toggle/队列，不能让先前ready/ack在新会话重放。

未来仲裁必须绑定事务级owner：AW/A接受后到WLAST及B完成、AR/A接受后到RLAST始终归同一client；W不能随每周期优先级切换。旧视频client固定ID可在外层补owner标签，新snapshot/global client独立ID或严格序列化。B/R真实错误须进入新job状态；旧视频响应不能被新client误计入栅栏。重置后迟到响应不得投递给新epoch。每次授予检查所属地址白名单、长度、4KiB边界及槽生命周期。

QoS拟采用实时FIFO水位优先，低频限额token、最多一个低频burst在途且发前有足够实时slack。候选低频max burst可从128降到16/32拍以缩短不可抢占段，代价是吞吐下降；当前模型未承诺其效率。必须证明`等待上界 < min(读FIFO可供像素时间,写FIFO剩余时间,快照FIFO剩余时间)`并计CDC延迟、prefetch、refresh、当前事务排空及安全guard。相机/HDMI不能回压；容量平均足够不等于这个不等式成立。当前没有该证明，故NO-GO。

复制前必须先原子reserve一个未leased、非pending的结果槽，状态转COPYING并锁定copy_slot；没有free槽就保持CONVERGED且不发任何结果写事务。COPYING槽不对consumer发布，不能被第二producer领取；全部复制B响应成功后才提交ready。协议模型已显式覆盖reserve-before-copy、copy期间不可见及双槽leased时未开始复制。

单descriptor mailbox规则：只要前一global_result_ready尚未consumer ACK，即便另一个结果DDR槽空闲也不允许reserve下一COPY，保持CONVERGED等待。ACK后可以占另一FREE槽；旧LEASED槽仍等release。已用软件测试覆盖pending不覆盖、ACK后继续以及COPYING中abort/reset导致隔离。
