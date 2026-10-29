# E4/E5关闭实验版：离线完成，待Work和用户独立A

本版直接执行用户“把E4、E5、E9阻断全部放开，不稳定再加检查”。取消候选孔洞bbox边距E4；删除全局512/局部32残边E5以及整个第二遍解释、残边RLE RAM和二次CCL。候选分类完成直接PUBLISH，未抬阈值、未换码、未以新的严格条件替代。原边缘链已没有E9光照门，本版核无BG ROM/四参考亮度/CAL资格依赖，不冒新修旧E9。仍保第一遍背景4CCL、只跨1/2个真实边缘像素合并内孔、原E3几何/未知孔、0–10、5120run/row128、2M服务、完整帧身份/TTL/三distinct确认。

因此开放轮廓、大杂边、边界残片可能被忽略或误计/漏计：原513/1024/2048散点现valid0，bbox9/15+边带33现valid1，厚双轨和闭环长尾现valid1，开大轮廓/gap3/夹边形状现valid0，四完整+退化第五仍可valid4。它们是明确授权的新行为，不能写成物理计数正确或画质全部通过。合成515个微孔总面积2060（与历史字段数值相似，不是现场RAW重建）产生6180边缘像素，模型/RTL现可valid0，不再触残边门。原E3依然可能拒绝未知大小孔洞，其他保留错误仍可能出现；不是所有阻断都关闭。实际5必须CURRENT5，否则实物不通过。

CURRENT/LAST诚实分开，扫描或无当前有效结果显示CURRENT--；右侧固定EXPERIMENT E4E5 OFF，删除UNEX/CAP512/CAP032及旧kind解释。新schema0x454f5001的word3复用capture EDGE19bit计数，早失败时是已捕获部分数量。HELD保持历史语义，不一定解释当前LIVE。全部文字y<90，RAW/EDGE仍实际GAU2 H48/L24+3×3closing，视频包延迟、时钟、管脚、720p、镜像、DDR均不变。

最终28个完整960×540 CCL案例与独立像素BFS面积/中心一致，逐拍禁止进入删除的71..77/80..88路径，真实发布且不出E4/E5/E9，最大服务617,807。13边界例包括5120可处理/5121和row129保E6、ID5119、候选贴边通过、SOF+EOF保E8、2M/TTL注入保E7；E3未知孔/11件EA、源support E8、event/非法state EF另核。22 jobs带256点3→2→3/5→4→5，三独立camera、jobbegin撤CURRENT、坏E3保LAST、重复camera不续期、恢复和TTL/完整64身份/新schema通过。OSD字符/ROI无遮挡/RAW-EDGE核过。

实际生产GAU2+closing+adapter+core十帧720p共9,216,000像素逐像素核RAW/edge/support；5个合成目标加32个灰度32的3×3噪点，父模型真实672未解释触E5，新版三确认CURRENT5，服务337,069；重复camera不续期、坏非job支持撤CURRENT保LAST5、空场恢复CURRENT0均过。interval/arm0、额外750,000检查空拍和末尾60,000drain明确为测试设置，不冒连续60Hz吞吐或DDR/实物验证。原native183912日志unexp标签实际打印capture EDGE，原日志保留；最终TB已改captured_edges并重绑。bbox16父预期4→0元数据勘误不改向量/生产，最终CCL收据重新绑定。一个源错误单元初稿在撤去坏像素后才采样组合frame_bad，已改为坏像素当拍采样并保留失败，生产未变。

fresh physical physical_20261027_184512：XLR24386/51680、RAM176/204、DSP3/128；CCL68RAM=bank65+row3，残边RAM0，恢复了原存储规模。I3 normal setup+0.211ns/hold+0.026ns，各200paths；19继承CDC选择器与实际clock一致，内部no_clock/unconstrained/multiple0，768诊断FF及6×64身份映射。继承外部7输入135输出、PLL异步SR/PVT/暖复位/窄裕量限制保留，不冒全PVT保证。99生产输入、98非顶层XML与镜像字节一致，顶层仅允许工具运行元数据，11路由DB SHA绑定。BIT reports/part_count_edge_open_20261027/artifacts/StarEye_CountEdgeOpen.bit，2511945B，SHA256 baa517a0d9cc742e488e4aee2137acc2c3b18992ffb1ff9d36fbf998a7a90f8c。

branch codex/m5c-fusion-prototype，HEAD 433a83e543cb40a52128d1eea4ae32ce83aecd16，parent b5f36414035193ab9c7aa8393732a93e10fe141e，未提交/no candidate commit。技术父tolerant524 manifest SHA 9d7474f2f29158a67a408d98becc13e29758973ff684bac500a23f3bb4d84661，A通过但实物未完整验收；本轮只新增open五目录，docs由Work负责。6686旧源/快照SHA保持，父源/私图不修改不复制。无Git/B/Programmer/下载/Flash。快照只含必要源、向量、日志、报告/映射摘录、DB SHA和BIT，不含完整map/路由DB实体，不声称可离线重算STA。下一门为用户另一个可见Codex对话独立A，当前不可上板。
