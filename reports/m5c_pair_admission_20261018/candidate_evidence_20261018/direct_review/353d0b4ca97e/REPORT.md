# V3远端有限验收提案

实际双阶段顺序、固定V3包100文件、工具身份一致性、编译和正常结束标记核对通过。原生完整运行7083.58秒，ModelSim SE-64 2020.4优化+acc；本地未执行收到的代码或新仿真。

严格串口共1,302,076字节/109包：type1=2、type4=102、types6–10各1，完整CRC/schema/身份通过。一个成功pair：attempt1、SID75、token7、current_source73。921600参考分类的八邻域BFS与mask一致；921600 current字节与原oracle一致，class/support/local独立gold逐像素一致。accepted-domain仅实际控制对照，不是独立资格真值。

真实1152次current B和1次metadata B、producerDone及尾部账本闭合；final像素前资格为真，自然EOF后eligible清零而稳定identity保持，metadata提交先于真实rel/ret及release。随后published2；七模式健康计数4/5/5/5/5/6/5。target130及102组SOURCE→UI→START→DONE→registered TAKE严格一致，PIX/UI各8安静边沿、全wire及orphan INPUT负向检查通过。

## 必须保留的证据缺陷

首次严格INPUTS核对失败，原件不改：63条INPUTS中backend错误沿用V2的23120B/SHA4cf64…，其余62条匹配。固定stage.py在结束后从历史ORIGINAL_63_INPUTS.original字段生成该表，不能声称它是当前正确pre-run清单。实际当前V3 backend为23623B/SHA25dc75…；两manager当前input_manifest、固定包100项、返回snapshot、实际编译argv/顺序/模块日志以及固定stage执行前后verify及成功标记构成独立版本闭环。详见RUNTIME_INPUT_RECONCILIATION.json，不补造remote prehash，不篡改原包。此处提出非阻断元数据缺陷供Work最终判定。

## 边界

条件DDR/加速UART仿真，不证明默认全速吞吐、硬件增强、热恢复或PVT。100us compatibility仅启动可见性。远端工具文件hash为远端归档provenance，本机未重新执行其二进制。三既有PLL异步SR未计时、外部7输入/135输出属于独立物理边界。固定V3工作快照不是新candidate。QQ workflow/账号/用户目录运维原件仅本地保存，不进入candidate或外部审查；不同于Work后来未发送任务ID。

全部验收为交Work内部签收的有限提案。未Git、bit转换、构建或硬件操作。
