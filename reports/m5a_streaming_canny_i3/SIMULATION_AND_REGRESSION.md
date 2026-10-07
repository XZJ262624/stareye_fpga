# 黄金模型、仿真和回归证据

软件黄金模型scripts/m5a_streaming_canny_gold.py用二维数组排序、中值、独立卷积、方向有理数和邻域集合定义，不复刻RTL状态。窗口顺序p00至p22为从左上到右下；Gy为上减下。NMS使用未饱和12位幅值，负侧严格>、正侧>=。全局连接不实现。边界和阈值0的行为由算法规格共同约束。

原四模式的比较是四套新colorize+OSD与四套原M4+OSD在相同中心坐标逐像素比较，包含OSD像素，不跳过OSD区域。小帧/CE暂停/完整720p均检查延迟队列、RGB、同步、坐标和算法诊断输出。固定720p全延迟6626拍；合法暂停为ce=0整体保持，DE=0正常消隐仍前进；非法DE洞单独测试恢复，不混称暂停。

详尽实际数量见BUILD_REPORT.md和sim/all_binding.json。sim/all_binding绑定输入、源、黄金脚本和实际运行日志；supplement/binding.json绑定HDMI通道及坏帧/复位恢复。生成向量、工作库、波形、临时日志只本地保存，不提交。故障注入检查编译日志、Loaded work、Fatal和非零退出，编译失败不能冒充正确拒绝。

主会话独立创建新的ModelSim库重编译而非信任队友PASS，结果ROOT_HDL_REVIEW.json；root_review/*.txt为独立运行文本。另采用列表sorted中值/嵌套卷积/坐标集合随机31×27、启用/旁路×阈值0/1/32/64/255，共8370像素与NumPy黄金一致。逐项源哈希与最终源一致，独立复核见ROOT_FINAL_REVIEW.json。

20项实际RTL变异、24项证据CLI负向及正常正向均通过；结果与隔离变异文件/日志哈希记录在RTL_FAULT_RESULTS.json和EVIDENCE_NEGATIVE_RESULTS.json。final_gate将负向证据与最终实现校验组合，避免把负向结果预先写死PASS或循环自引用。
