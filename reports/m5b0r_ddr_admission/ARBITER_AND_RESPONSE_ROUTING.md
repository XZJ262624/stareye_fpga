# 隔离仲裁原型
m5b0r_arbiter不接入生产工程、也不纳入诊断bit。三个客户端：0相机写、1HDMI读、2后台读写；按真实统一A+W/B/R结构设计，固定128bit、ID8，单owner槽。

实时urgent优先且两路轮转。非urgent时两次RT后允许一次BG，必须safe_window且有credit；默认BG最多32拍/512B、refill512周期。已受理A/B/R/W保持原owner，burst不可抢断。下游ID映射owner+1，上游恢复原ID；错误ID/长度不发错客户端，进入quarantine并要求控制器reset_ack。

原型地址whitelist：RT前16MiB、BG候选区，参数仅用于隔离模型，未写入任何生产工程。invalid请求采用c_aready+rejected拒绝契约，客户端必须消费rejected作为本请求终结；不是标准AXI DECERR桥。

所有soft_reset、错误quarantine和watchdog reset_request均采用显式组合client_cancel=soft_reset||quarantine||reset_request，集成侧必须在同一UI采样边界取消全部客户端旧epoch。soft_reset明确是整组客户端epoch取消事件：旧B/R不再呈现，客户端须同步取消旧响应期待；旧W生产者在实际controller reset_ack前仍提供原burst，否则watchdog请求硬复位。没有这个客户端取消契约不能直接用于生产。仅真实DDR复位且全部客户端epoch刷新后才可置ddr_reset_ack；不能凭软件pulse伪造安全ACK。

响应BRESP/RRESP错误保留并路由原owner，是可恢复事务结果；ID/RLAST/WLAST错及超时进入quarantine。后台公平仅在safe_window反复出现、urgent并非永久保持且环境响应有界时成立，持续urgent不保证后台进展。
