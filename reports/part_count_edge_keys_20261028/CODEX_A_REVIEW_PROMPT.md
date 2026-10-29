你是用户在独立可见对话中委派的 Codex A，只读审查本次工业计件按键阈值独立版，不能由本轮内部Writer/Work替代。

工作目录 F:/Projects/stareye_fpga。branch `codex/m5c-fusion-prototype`，基线 HEAD `38d7e42f42ab92f7892072bf18d470445c9d4bd0`，parent `433a83e543cb40a52128d1eea4ae32ce83aecd16`。**尚未提交的固定源码快照，不是candidate commit**。技术父为 `reports/part_count_edge_open_20261027/review_snapshot/MANIFEST.json`，SHA `3f566c51b323be799bc71e67cb3aeed252945471361f025db29b39576d2aca9f`，已审423项；原BIT SHA baa517a0d9cc742e488e4aee2137acc2c3b18992ffb1ff9d36fbf998a7a90f8c。当前HEAD是另一回放任务，不把它称计件技术父。

只读 `reports/part_count_edge_keys_20261028/review_snapshot_v2/MANIFEST.json` 及其 `source` 冻结树。manifest SHA256 `d2a449a7b3e60bd7cec1b059a9904cdd91da970a3961b660eb05880389479fb1`，304项。先逐项验证SHA与范围；只审该快照相对技术父的实际新增/差异，`SOURCE_DIFF_TECHNICAL_PARENT.patch`和完整源可用；基线HEAD身份另记FINAL_IDENTITY.json。不要审持续变化的工作区。首份review_snapshot因误纳可变watcher状态已废弃，技术源码/BIT/测试不变。

重点：K1减/K2加，默认48/24、步8、8..128饱和、20ms防抖、单长只一次、双短仅RAW/MSK、双长仅诊断；真实source SOF阈值/generation同拍旁路，m5a真实值与adapter/OSD同帧一致、不增视频延迟；64位代避免ABA、忙中撤旧、LAST保留、饱和/view不撤；沿用原CCL/closing及三确认，不引回E4/E5/E9或新的图像门；新字段全部pix域且19已有CDC/SDC维持。

必要证据见BUILD_REPORT.md、TEST_SUMMARY.json、STAGE1_RESULT.json、VIDEO_ORACLE.json、NEW_CONFIG_CLOCK_PROOF.json、BUILD_RESULT.json、BASIC_STA_RESULT.json及对应原生日志。8帧完整720p/7372800像素/8job/4真实按键、29次短门事件与7小ROI真CCLjob、OSD极值22176像素已过。fixture无真实DDR服务，帧后750000空白拍；不是实际fps测试。原失败日志保留。

新BIT `reports/part_count_edge_keys_20261028/artifacts/StarEye_CountEdgeKeys.bit`，2549817B，SHA `a1b3ad05a379a096c9bbcec1bf00c08c6a183002bf5c1bf4dc1d1fcb28c366fb`；fresh资源26087XLR/176RAM10/3DSP，basic normal I3 setup/hold +0.197/+0.014ns，19组CDC与原生查询通过。PLL SR/PVT/暖复位/外部7输入135输出和窄hold限制保持；开放轮廓仍漏计，阈值降低可能增噪，不保证实物收益。

禁止修改、暂存、提交、推送、运行Programmer、下载、写Flash或调用其他审查者；本轮未交DeepSeek B。问题表列“严重程度、文件/位置、问题、证据、影响、建议”，结论只能PASS/PASS_WITH_FINDINGS/FAIL。A完成前不得读B报告。仅用户反馈后Work才能进入指定BIT实物门。
