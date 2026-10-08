# M5B.0R独立DDR诊断构建报告
2026-10-08，Efinity2025.1.110.5.9，Titanium/Ti60F225/FBGA225/I3，m5b0r_top。

官方工程/接口API创建独立副本；DDR v5.14全部配置、DDRPLL192/384MHz和DDRGPIO与M2保持，源码/ROMSHA相等。24MHz脚改普通core输入+sysPLL CORE参考，用于独立监视，已官方check_design及P&R；不是原M2入口路由全部不变。保留generator core clock network delay提示与CORE reference INFO，未将其宣称跨PVT完整建模证明。

完整map/interface/P&R/bitstream生成退出0。已约束STA setup/hold最小+0.100/+0.021ns，窄hold边界保留。资源7391 XLR/30 RAM10/0 DSP；这些是诊断工程结果，仲裁未集成，不能作为M5B.1资源/时序。

独立数据库克隆STA，64份DQ逐lane和全局/DDR输入输出报告必需全部存在；实际报告数量及无路径clock pair见final_audit/binding.json。0无时钟、0内部未约束、0多时钟；2无输入延迟是PLL lock，17无输出延迟=6LED+2PLLreset+9shift控制。未添加假LED延迟掩盖未约束。

SDC同源period统一10.416/5.208/2.604ns、ref41.664ns（64ppm保守量化，不提高硬件频率）；DDR原IO延迟不改。仅20个由综合网表SR_SYNC=0确认的复位链SR引脚逐一例外，启动CYCLE4同步释放D路径和DDR数据继续timed。monitor同步路径未泛切。详情CONSTRAINT_DERIVATION.json及最终audit逐端点匹配。

最终本轮详细告警52条，新增诊断逻辑告警0条（累计warn.log包含旧轮次，不混算），DDR IP噪声/未用端口见WARNING_CLASSIFICATION.json。4个DQS_N输入在已用DDR实现中未使用，不是4个DQ数据lane缺失。所有32个DQ输入半拍分别STA。关键约束/PVT边界继续保留。

首轮完整build但负STA、初始输出初始化警告及复合selector未匹配的失败过程已复核；build_attempt_1保留，未把失败bit当最终验证通过。主会话修复专用故障复位锁存毛刺风险、初始化输出、周期精度和实际端点匹配后重新完整构建。

最终bit 2157846字节，SHA256 `249b4b5e4095da1e7466f94d510c17de4588161c37de484a0eff427304cef3f3`，路径`../../efinity/m5b0r_ddr_address_diag_i3/outflow/M5B0R_DdrDiag.bit`。绑定最终源码/实现/STA和bit见EVIDENCE_BINDING.json；bit不暂存、不提交。

实物未执行。软件/HDL模型及本诊断受约束STA通过，不证明高地址无保留区、实际校准PASS或实时视频共存。Gate NO_GO。

## 最后一次实现修订
Astra独立审查指出总体超时与事务enable下降的遥测可能混淆。主会话增加调度器F1/F2/40|phase/80|phase专用stage、定向总体计数边界注入用例并重新完整编译与112份STA。最终资源7391 XLR/30 RAM10/0 DSP；setup/hold +0.100/+0.021ns。此前+0.097/+0.007ns及旧bit仅属于修订前实现，不能用于当前bit验收。
最终32个DQ半拍各setup/hold齐全，32个无路径时钟对未伪造报告；20个复位链SR selector各匹配1。最终详细综合告警52条（其中含VERI及其他WARNING类别），新诊断逻辑告警0。遥测stage修订与最终源码、实现输出、STA、bit相互绑定，见EVIDENCE_BINDING.json。

构建前后输入差异仅为工程XML的根属性last_change由1791437898更新为1791438891；已从旧审计副本按before SHA定位原XML，非根属性及所有子元素逐项一致，见BUILD_XML_METADATA_CHANGE.json。SDC、RTL与IP输入字节未变；不把XML整个字节声称为未变。
